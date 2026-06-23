@isTest
global class AhaErlControllerTest {

	private static final String ADMIN_PERMISSION_SET_NAME = 'ERL_Full_Access';

	private static User createUser(String seed) {
		String unique = String.valueOf(System.now().getTime());
		User u = new User(
			Username = 'erl.' + seed + '.' + unique + '@example.test',
			LastName = 'Test',
			Email = 'erl.' + seed + '.' + unique + '@example.test',
			Alias = seed.length() > 8 ? seed.substring(0, 8) : seed,
			TimeZoneSidKey = 'Europe/London',
			LocaleSidKey = 'en_GB',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			ProfileId = UserInfo.getProfileId()
		);  
		insert u;
		return u;
	}

	private static void assignAdminPermissionSet(User userRecord) {
		List<PermissionSet> permissionSets = [SELECT Id
											  FROM PermissionSet
											  WHERE Name = :ADMIN_PERMISSION_SET_NAME
											  LIMIT 1];
		System.assertEquals(1, permissionSets.size(), 'Expected ERL admin permission set to exist for tests');
		System.runAs(userRecord) {  
			insert new PermissionSetAssignment(
				AssigneeId = userRecord.Id,
				PermissionSetId = permissionSets[0].Id
			);
		}
	}

	private static String createCloneSourceData() {
		String sourceName = 'Source-' + String.valueOf(System.now().getTime());
		String shortSorCode = 'S' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L));
		AHA_ERL_Code_Profile__c sourceProfile = new AHA_ERL_Code_Profile__c(
			Name = sourceName,
			ExternalIdentifier__c = sourceName,
			Description__c = 'Source profile'
		);
		insert sourceProfile;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Clone Category',
			EditModeLabel__c = 'Clone Category',
			ExternalIdentifier__c = 'Cat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sorCode = new AHA_ERL_Code__c(
			SORCodeText__c = shortSorCode,
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert sorCode;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(
				SORProfile__c = sourceProfile.Id,
				SORCategory__c = category.Id
			),
			new AHA_ERL_Junction__c(
				SORProfile__c = sourceProfile.Id,
				SORCode__c = sorCode.Id
			)
		};

		return sourceName;
	}

	@isTest
	static void updateSORCategoryCoordsUpdatesValuesForValidId() {
		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Coords Category',
			EditModeLabel__c = 'Coords Category',
			ExternalIdentifier__c = 'Coords-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Map<String, String> params = new Map<String, String>{
			'id' => category.Id,
			'x' => '15%',
			'y' => '30%'
		};

		Test.startTest();
		Boolean result = AhaErlController.updateSORCategoryCoords(params);
		Test.stopTest();

		System.assertEquals(true, result,
			'Valid category id should return true');

		AHA_ERL_Category__c refreshed = [SELECT Layout_Left__c, Layout_Top__c
									 FROM AHA_ERL_Category__c
									 WHERE Id = :category.Id
									 LIMIT 1];
		System.assertEquals('15%', refreshed.Layout_Left__c,
			'Layout left coordinate should be updated');
		System.assertEquals('30%', refreshed.Layout_Top__c,
			'Layout top coordinate should be updated');
	}

	@isTest
	static void updateSORCategoryCoordsReturnsFalseForInvalidId() {
		Map<String, String> params = new Map<String, String>{
			'id' => 'not-an-id',
			'x' => '10%',
			'y' => '20%'
		};

		Test.startTest();
		Boolean result = AhaErlController.updateSORCategoryCoords(params);
		Test.stopTest();

		System.assertEquals(false, result,
			'Invalid id should be handled and return false');
	}

	@isTest
	static void newBlankProfileReturnsErrorWhenUserIsNotAdmin() {
		User nonAdminUser = createUser('nonadmin');
		String profileName = 'NoPerm-' + String.valueOf(System.now().getTime());

		System.runAs(nonAdminUser) {
			Test.startTest();
			String result = AhaErlController.newBlankProfile(profileName);
			Test.stopTest();

			System.assertEquals('error: you do not have permission to add this', result,
				'Method should block profile creation when user lacks ERL administration permission');
		}

		System.assertEquals(0, [SELECT COUNT()
								FROM AHA_ERL_Code_Profile__c
								WHERE Name = :profileName],
			'Profile should not be inserted when access is denied');
	}

	@isTest
	static void newBlankProfileCreatesProfileForAdminUser() {
		User adminUser = createUser('adminok');
		assignAdminPermissionSet(adminUser);
		String profileName = 'AdminCreate-' + String.valueOf(System.now().getTime());

		System.runAs(adminUser) {
			Test.startTest();
			String result = AhaErlController.newBlankProfile(profileName);
			Test.stopTest();

			System.assertEquals('Successfully Added', result,
				'Method should return success when admin user creates a new profile');
		}

		AHA_ERL_Code_Profile__c insertedProfile = [SELECT Id, Name, ExternalIdentifier__c
												   FROM AHA_ERL_Code_Profile__c
												   WHERE Name = :profileName
												   LIMIT 1];
		System.assertEquals(profileName, insertedProfile.Name,
			'Inserted profile should use the provided name');
		System.assertEquals(profileName, insertedProfile.ExternalIdentifier__c,
			'External identifier should match the provided profile name');
	}

	@isTest
	static void newBlankProfileReturnsDmlErrorForInvalidInput() {
		User adminUser = createUser('adminerr');
		assignAdminPermissionSet(adminUser);

		Integer profileCountBefore = [SELECT COUNT() FROM AHA_ERL_Code_Profile__c];
		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.newBlankProfile(null);
			Test.stopTest();
		}

		Integer profileCountAfter = [SELECT COUNT() FROM AHA_ERL_Code_Profile__c];

		System.assert(result != null && result.startsWith('error:'),
			'Method should return an error when called with an invalid profile name');
		System.assertEquals(profileCountBefore, profileCountAfter,
			'No profile should be inserted when DML fails');
	}

	@isTest
	static void cloneProfileReturnsErrorWhenUserIsNotAdmin() {
		User nonAdminUser = createUser('clonenoadm');
		String result;

		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.cloneProfile('AnySource', 'Any Desc', 'AnyClone');
			Test.stopTest();
		}

		System.assertEquals('error: you do not have permission to clone this', result,
			'Method should block clone for users without ERL administration permission');
	}

	@isTest
	static void cloneProfileClonesProfileAndJunctionsForAdmin() {
		User adminUser = createUser('cloneok');
		assignAdminPermissionSet(adminUser);
		String sourceProfileName = createCloneSourceData();
		String clonedName = 'Cloned-' + String.valueOf(System.now().getTime());

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.cloneProfile(sourceProfileName, 'Cloned description', clonedName);
			Test.stopTest();
		}

		System.assertEquals('Successfully Cloned', result,
			'Admin should be able to clone a profile successfully');

		AHA_ERL_Code_Profile__c cloned = [SELECT Id, Name, Description__c, ExternalIdentifier__c
										   FROM AHA_ERL_Code_Profile__c
										   WHERE Name = :clonedName
										   LIMIT 1];
		System.assertEquals('Cloned description', cloned.Description__c,
			'Cloned profile should persist the provided description');
		System.assertEquals(clonedName, cloned.ExternalIdentifier__c,
			'Cloned profile external identifier should match the new profile name');

		Integer sourceJunctionCount = [SELECT COUNT()
									FROM AHA_ERL_Junction__c
									WHERE SORProfile__r.Name = :sourceProfileName];
		Integer clonedJunctionCount = [SELECT COUNT()
									FROM AHA_ERL_Junction__c
									WHERE SORProfile__c = :cloned.Id];
		System.assertEquals(sourceJunctionCount, clonedJunctionCount,
			'All source junction rows should be cloned to the new profile');

		Integer clonedCategoryRows = [SELECT COUNT()
								  FROM AHA_ERL_Junction__c
								  WHERE SORProfile__c = :cloned.Id
								    AND SORCategory__c != null];
		Integer clonedCodeRows = [SELECT COUNT()
								  FROM AHA_ERL_Junction__c
								  WHERE SORProfile__c = :cloned.Id
								    AND SORCode__c != null];
		System.assert(clonedCategoryRows > 0,
			'Cloned profile should include category assignments');
		System.assert(clonedCodeRows > 0,
			'Cloned profile should include SOR code assignments');
	}

	@isTest
	static void cloneProfileReturnsErrorForInvalidCloneName() {
		User adminUser = createUser('cloneerr');
		assignAdminPermissionSet(adminUser);
		String sourceProfileName = createCloneSourceData();

		Integer beforeCount = [SELECT COUNT() FROM AHA_ERL_Code_Profile__c];
		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.cloneProfile(sourceProfileName, 'Desc', null);
			Test.stopTest();
		}
		Integer afterCount = [SELECT COUNT() FROM AHA_ERL_Code_Profile__c];

		System.assert(result != null && result.startsWith('error:'),
			'Method should return an error when clone profile name is invalid');
		System.assertEquals(beforeCount, afterCount,
			'No new profile should be inserted when clone fails');
	}

	@isTest
	static void deleteProfileReturnsErrorWhenUserIsNotAdmin() {
		String profileName = 'DeleteNoPerm-' + String.valueOf(System.now().getTime());
		insert new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);

		User nonAdminUser = createUser('delnoadm');
		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.deleteProfile(profileName);
			Test.stopTest();
		}

		System.assertEquals('error: you do not have permission to delete this', result,
			'Method should reject delete attempts from non-admin users');
		System.assertEquals(1, [SELECT COUNT()
							   FROM AHA_ERL_Code_Profile__c
							   WHERE Name = :profileName],
			'Profile should remain when delete is denied');
	}

	@isTest
	static void deleteProfileProtectsAllAndDefaultProfiles() {
		User adminUser = createUser('delguard');
		assignAdminPermissionSet(adminUser);

		insert new List<AHA_ERL_Code_Profile__c>{
			new AHA_ERL_Code_Profile__c(Name = 'ALL', ExternalIdentifier__c = 'ALL'),
			new AHA_ERL_Code_Profile__c(Name = 'Default', ExternalIdentifier__c = 'Default')
		};

		String allResult;
		String defaultResult;
		System.runAs(adminUser) {
			Test.startTest();
			allResult = AhaErlController.deleteProfile('ALL');
			defaultResult = AhaErlController.deleteProfile('Default');
			Test.stopTest();
		}

		System.assertEquals('error: Cannot delete all-container profile', allResult,
			'ALL profile should be explicitly protected');
		System.assertEquals('error: Cannot delete default profile', defaultResult,
			'Default profile should be explicitly protected');
		System.assertEquals(1, [SELECT COUNT() FROM AHA_ERL_Code_Profile__c WHERE Name = 'ALL'],
			'ALL profile should not be deleted');
		System.assertEquals(1, [SELECT COUNT() FROM AHA_ERL_Code_Profile__c WHERE Name = 'Default'],
			'Default profile should not be deleted');
	}

	@isTest
	static void deleteProfileDeletesRegularProfileForAdmin() {
		User adminUser = createUser('delok');
		assignAdminPermissionSet(adminUser);

		String profileName = 'DeleteMe-' + String.valueOf(System.now().getTime());
		insert new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.deleteProfile(profileName);
			Test.stopTest();
		}

		System.assertEquals('Successfully Deleted', result,
			'Admin should be able to delete a non-protected profile');
		System.assertEquals(0, [SELECT COUNT()
							   FROM AHA_ERL_Code_Profile__c
							   WHERE Name = :profileName],
			'Profile should be deleted after successful call');
	}

	@isTest
	static void addCategoryReturnsErrorWhenUserIsNotAdmin() {
		User nonAdminUser = createUser('addcatna');
		String profileName = 'AddCatProfile-' + String.valueOf(System.now().getTime());
		insert new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);

		Map<String, String> details = new Map<String, String>{
			'label' => 'Denied Category ' + String.valueOf(System.now().getTime()),
			'editModeLabel' => 'Denied',
			'imageFileText' => 'img.jpg',
			'isGuided' => 'false'
		};

		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.addCategory(details, new List<String>{ profileName });
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to add this', result,
			'Non-admin users should not be able to add categories');
		System.assertEquals(0, [SELECT COUNT()
							   FROM AHA_ERL_Category__c
							   WHERE Label__c = :details.get('label')],
			'Category should not be created when access is denied');
	}

	@isTest
	static void addCategoryCreatesRootCategoryAndAllProfileForAdmin() {
		User adminUser = createUser('addcatok');
		assignAdminPermissionSet(adminUser);

		String targetProfileName = 'TargetProfile-' + String.valueOf(System.now().getTime());
		insert new AHA_ERL_Code_Profile__c(
			Name = targetProfileName,
			ExternalIdentifier__c = targetProfileName
		);

		Map<String, String> details = new Map<String, String>{
			'label' => 'Root Category ' + String.valueOf(System.now().getTime()),
			'editModeLabel' => 'Root Edit',
			'imageFileText' => 'root.jpg',
			'isGuided' => 'true'
		};

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.addCategory(details, new List<String>{ targetProfileName });
			Test.stopTest();
		}

		System.assertEquals('Successfully Added', result,
			'Admin should be able to add a root category');

		AHA_ERL_Category__c createdCategory = [SELECT Id, Label__c, EditModeLabel__c, ImageFileText__c, Guided__c, ParentCategoryLookup__c
										   FROM AHA_ERL_Category__c
										   WHERE Label__c = :details.get('label')
										   LIMIT 1];
		System.assertEquals('Root Edit', createdCategory.EditModeLabel__c,
			'Edit-mode label should be persisted');
		System.assertEquals('root.jpg', createdCategory.ImageFileText__c,
			'Image file text should be persisted');
		System.assertEquals(true, createdCategory.Guided__c,
			'Guided flag should be set from input');
		System.assertEquals(null, createdCategory.ParentCategoryLookup__c,
			'Root category should not have a parent');

		System.assertEquals(1, [SELECT COUNT() FROM AHA_ERL_Code_Profile__c WHERE Name = 'ALL'],
			'ALL profile should be auto-created for root category creation when missing');

		Set<String> assignedProfiles = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									FROM AHA_ERL_Junction__c
									WHERE SORCategory__c = :createdCategory.Id]) {
			assignedProfiles.add(j.SORProfile__r.Name);
		}
		System.assert(assignedProfiles.contains(targetProfileName),
			'Provided profile should be assigned to the new category');
		System.assert(assignedProfiles.contains('ALL'),
			'ALL profile should always be assigned to new categories');
	}

	@isTest
	static void addCategoryReturnsErrorWhenProfileDoesNotExist() {
		User adminUser = createUser('addcaterr');
		assignAdminPermissionSet(adminUser);

		Map<String, String> details = new Map<String, String>{
			'label' => 'Error Category ' + String.valueOf(System.now().getTime()),
			'editModeLabel' => 'Err',
			'isGuided' => 'false'
		};

		String missingProfileName = 'Missing-' + String.valueOf(System.now().getTime());
		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.addCategory(details, new List<String>{ missingProfileName });
			Test.stopTest();
		}

		System.assert(result != null && result.startsWith('error:'),
			'Method should return an error when a provided profile cannot be resolved');
	}

	@isTest
	static void deleteCategoryReturnsErrorWhenUserIsNotAdmin() {
		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Delete Denied ' + String.valueOf(System.now().getTime()),
			EditModeLabel__c = 'Delete Denied',
			ExternalIdentifier__c = 'DeleteDenied-' + String.valueOf(System.now().getTime())
		);
		insert category;

		User nonAdminUser = createUser('delcatna');
		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.deleteCategory(category.Id);
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to delete this', result,
			'Non-admin users should not be able to delete categories');
		System.assertEquals(1, [SELECT COUNT() FROM AHA_ERL_Category__c WHERE Id = :category.Id],
			'Category should remain when delete is denied');
	}

	@isTest
	static void deleteCategoryDeletesCategoryForAdmin() {
		User adminUser = createUser('delcatok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Delete OK ' + String.valueOf(System.now().getTime()),
			EditModeLabel__c = 'Delete OK',
			ExternalIdentifier__c = 'DeleteOK-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.deleteCategory(category.Id);
			Test.stopTest();
		}

		System.assertEquals('Successfully Deleted', result,
			'Admin should be able to delete categories');
		System.assertEquals(0, [SELECT COUNT() FROM AHA_ERL_Category__c WHERE Id = :category.Id],
			'Category should be deleted after successful call');
	}

	@isTest
	static void deleteCategoryReturnsSuccessForNonMatchingId() {
		User adminUser = createUser('delcaterr');
		assignAdminPermissionSet(adminUser);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.deleteCategory('not-an-id');
			Test.stopTest();
		}

		System.assertEquals('Successfully Deleted', result,
			'Method currently treats non-matching ids as a no-op delete and returns success');
	}

	@isTest
	static void getAllProfilesReturnsOrderedProfiles() {
		String profileAName = 'AProfile-' + String.valueOf(System.now().getTime());
		String profileBName = 'BProfile-' + String.valueOf(System.now().getTime());
		insert new List<AHA_ERL_Code_Profile__c>{
			new AHA_ERL_Code_Profile__c(
				Name = profileBName,
				ExternalIdentifier__c = profileBName,
				Description__c = 'B Desc',
				Guided__c = true
			),
			new AHA_ERL_Code_Profile__c(
				Name = profileAName,
				ExternalIdentifier__c = profileAName,
				Description__c = 'A Desc',
				Guided__c = false
			)
		};

		Test.startTest();
		List<AHA_ERL_Code_Profile__c> profiles = AhaErlController.getAllProfiles();
		Test.stopTest();

		Integer indexA = -1;
		Integer indexB = -1;
		for (Integer i = 0; i < profiles.size(); i++) {
			if (profiles[i].Name == profileAName) {
				indexA = i;
			}
			if (profiles[i].Name == profileBName) {
				indexB = i;
			}
		}

		System.assert(indexA >= 0 && indexB >= 0,
			'Both inserted profiles should be returned by getAllProfiles');
		System.assert(indexA < indexB,
			'Profiles should be returned in ascending Name order');
	}

	@isTest
	static void getSORRootCategoriesReturnsOnlyRootCategoriesForProfile() {
		String profileName = 'RootProfile-' + String.valueOf(System.now().getTime());
		String rootLabel = 'Root Label ' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		AHA_ERL_Category__c rootCategory = new AHA_ERL_Category__c(
			Label__c = rootLabel,
			EditModeLabel__c = 'Root Edit',
			ImageFileText__c = 'root.jpg',
			ExternalIdentifier__c = 'Root-' + String.valueOf(System.now().getTime())
		);
		insert rootCategory;

		AHA_ERL_Category__c childCategory = new AHA_ERL_Category__c(
			Label__c = 'Child Label ' + String.valueOf(System.now().getTime()),
			EditModeLabel__c = 'Child Edit',
			ParentCategoryLookup__c = rootCategory.Id,
			ExternalIdentifier__c = 'Child-' + String.valueOf(System.now().getTime())
		);
		insert childCategory;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = rootCategory.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = childCategory.Id)
		};

		Test.startTest();
		List<AhaErlController.SORResponse> roots = AhaErlController.getSORRootCategories(profileName);
		Test.stopTest();

		System.assertEquals(1, roots.size(),
			'Only root categories should be returned by getSORRootCategories');
		System.assertEquals(rootCategory.Id, roots[0].id,
			'Returned root category id should match inserted root category');
		System.assertEquals(rootLabel, roots[0].label,
			'Label should be populated from category');
	}

	@isTest
	static void getSORCategoryReturnsChildrenForStandardCategory() {
		String profileName = 'ChildProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		AHA_ERL_Category__c parentCategory = new AHA_ERL_Category__c(
			Label__c = 'Parent Label',
			EditModeLabel__c = 'Parent Edit',
			ExternalIdentifier__c = 'Parent-' + String.valueOf(System.now().getTime())
		);
		insert parentCategory;

		AHA_ERL_Category__c childA = new AHA_ERL_Category__c(
			Label__c = 'Child A',
			EditModeLabel__c = 'Child A Edit',
			ParentCategoryLookup__c = parentCategory.Id,
			ExternalIdentifier__c = 'ChildA-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Category__c childB = new AHA_ERL_Category__c(
			Label__c = 'Child B',
			EditModeLabel__c = 'Child B Edit',
			ParentCategoryLookup__c = parentCategory.Id,
			ExternalIdentifier__c = 'ChildB-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Category__c>{ childA, childB };

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = childA.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = childB.Id)
		};

		Test.startTest();
		List<AhaErlController.SORResponse> children = AhaErlController.getSORCategory(parentCategory.Id, profileName);
		Test.stopTest();

		System.assertEquals(2, children.size(),
			'getSORCategory should return assigned child categories for the parent');
		for (AhaErlController.SORResponse sor : children) {
			System.assertEquals(false, sor.hasGuidance,
				'Non-closeup branch should not set guidance flag by default');
		}
	}

	@isTest
	static void getSORCategoryCloseupReturnsButtonsAndGuidance() {
		String profileName = 'CloseupProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		AHA_ERL_Category__c rootParent = new AHA_ERL_Category__c(
			Label__c = 'Top Parent',
			EditModeLabel__c = 'Top Parent Edit',
			ExternalIdentifier__c = 'TopParent-' + String.valueOf(System.now().getTime())
		);
		insert rootParent;

		Id closeupRecordTypeId = Schema.SObjectType.AHA_ERL_Category__c.getRecordTypeInfosByDeveloperName()
			.get('RepairLocationCloseup').getRecordTypeId();
		AHA_ERL_Category__c closeup = new AHA_ERL_Category__c(
			Label__c = 'Closeup Child',
			EditModeLabel__c = 'Closeup Edit',
			ParentCategoryLookup__c = rootParent.Id,
			RecordTypeId = closeupRecordTypeId,
			ExternalIdentifier__c = 'Closeup-' + String.valueOf(System.now().getTime())
		);
		insert closeup;

		AHA_ERL_Category__c buttonCategory = new AHA_ERL_Category__c(
			Label__c = 'Button One',
			EditModeLabel__c = 'Button One Edit',
			ParentCategoryLookup__c = closeup.Id,
			Layout_Left__c = '10px',
			Layout_Top__c = '20px',
			ExternalIdentifier__c = 'Button-' + String.valueOf(System.now().getTime())
		);
		insert buttonCategory;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = closeup.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = buttonCategory.Id)
		};

		AHA_ERL_Guidance__c guidance = new AHA_ERL_Guidance__c(
			Guidance_Text__c = 'Guidance body'
		);
		insert guidance;
		insert new AHA_ERL_Category_Guidance_Junction__c(
			Category__c = closeup.Id,
			Profile__c = profile.Id,
			Guidance__c = guidance.Id
		);

		Test.startTest();
		List<AhaErlController.SORResponse> response = AhaErlController.getSORCategory(rootParent.Id, profileName);
		Test.stopTest();

		System.assertEquals(1, response.size(),
			'Closeup branch should return the closeup child category');
		System.assertEquals(true, response[0].hasGuidance,
			'Guidance flag should be true when a category/profile guidance exists');
		System.assertEquals('Guidance body', response[0].guidance,
			'Guidance text should be mapped to response');
		System.assertNotEquals(null, response[0].buttons,
			'Buttons list should be initialized for closeup categories');
		System.assertEquals(1, response[0].buttons.size(),
			'Assigned child button categories should be included');
		System.assertEquals(buttonCategory.Id, response[0].buttons[0].id,
			'Button id should map from child category id when no redirect is set');
		System.assertEquals('10px', response[0].buttons[0].layoutLeft,
			'Button x coordinate should be mapped');
		System.assertEquals('20px', response[0].buttons[0].layoutTop,
			'Button y coordinate should be mapped');
	}

	@isTest
	static void getLocationsReturnsExpectedEntries() {
		Test.startTest();
		Map<String, String> locations = AhaErlController.getLocations();
		Test.stopTest();

		System.assertNotEquals(null, locations,
			'Locations map should not be null');
		System.assert(locations.containsKey('KIT - Kitchen'),
			'Locations should include known key KIT - Kitchen');
		System.assertEquals('KIT - Kitchen', locations.get('KIT - Kitchen'),
			'Locations value should match expected display text');
		System.assert(locations.size() > 10,
			'Hardcoded location map should contain many entries');
	}

	@isTest
	static void getSORsForButtonReturnsNestedSorAndMessagePayload() {
		String profileName = 'ButtonProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		AHA_ERL_Category__c buttonRoot = new AHA_ERL_Category__c(
			Label__c = 'Button Root',
			EditModeLabel__c = 'Button Root Edit',
			ExternalIdentifier__c = 'ButtonRoot-' + String.valueOf(System.now().getTime())
		);
		insert buttonRoot;

		AHA_ERL_Category__c itemList = new AHA_ERL_Category__c(
			Label__c = 'Item List',
			EditModeLabel__c = 'Item List Edit',
			ParentCategoryLookup__c = buttonRoot.Id,
			ExternalIdentifier__c = 'ItemList-' + String.valueOf(System.now().getTime())
		);
		insert itemList;

		AHA_ERL_Category__c subCategory = new AHA_ERL_Category__c(
			Label__c = 'Sub List',
			EditModeLabel__c = 'Sub List Edit',
			ParentCategoryLookup__c = itemList.Id,
			ExternalIdentifier__c = 'SubList-' + String.valueOf(System.now().getTime())
		);
		insert subCategory;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = itemList.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCategory__c = subCategory.Id)
		};

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();

		AHA_ERL_Code__c sorCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'S' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L)),
			SORHeadingText__c = 'SOR Heading',
			SORDescriptionText__c = 'SOR Description',
			DefaultLocation__c = 'KIT',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 2,
			SORRateCurrency__c = 12.34,
			SORFullDescriptionLongText__c = 'Full text',
			Trade__c = 'General',
			RecordTypeId = sorRecordTypeId
		);
		insert sorCode;

		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'M' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L)),
			Message__c = 'Message body',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = sorCode.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = messageCode.Id)
		};

		insert new List<AHA_ERL_Category_Junction__c>{
			new AHA_ERL_Category_Junction__c(AHA_ERL_Category__c = itemList.Id, AHA_ERL_Code__c = sorCode.Id),
			new AHA_ERL_Category_Junction__c(AHA_ERL_Category__c = subCategory.Id, AHA_ERL_Code__c = messageCode.Id)
		};

		Test.startTest();
		List<AhaErlController.AvailableSORList> response = AhaErlController.getSORsForButton(buttonRoot.Id, profileName);
		Test.stopTest();

		System.assertEquals(1, response.size(),
			'Should return one top-level item list category');
		System.assertEquals(itemList.Id, response[0].id,
			'Top-level category should match assigned item list');
		System.assertNotEquals(null, response[0].sorList,
			'Top-level sorList should be initialized');
		System.assertEquals(1, response[0].sorList.size(),
			'Top-level sorList should include non-message SORs');
		System.assertEquals(sorCode.Id, response[0].sorList[0].id,
			'SOR id should map into sorList entries');
		System.assertEquals(2, response[0].sorList[0].quantity,
			'Default quantity should map into AvailableSORs quantity');

		System.assertEquals(1, response[0].subCategories.size(),
			'Sub-category should be nested under top-level item list');
		System.assertEquals(subCategory.Id, response[0].subCategories[0].id,
			'Nested sub-category id should match setup data');
		System.assertEquals(1, response[0].subCategories[0].messages.size(),
			'Message-type codes should be placed in messages list');
		System.assertEquals('Message body', response[0].subCategories[0].messages[0].message,
			'Message text should map from message SOR code');
	}

	@isTest
	static void getAllSORForBrowseGroupsCodesByCategoryAndSubcategory() {
		String profileName = 'BrowseProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();

		AHA_ERL_Code__c groupedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'G' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L)),
			SORHeadingText__c = 'Grouped Heading',
			SORDescriptionText__c = 'Grouped Desc',
			Category__c = 'Plumbing',
			SubCategory__c = 'Leaks',
			DefaultLocation__c = 'KIT',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			SORRateCurrency__c = 22.22,
			Trade__c = 'Plumber',
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c undefinedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'U' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L)),
			SORHeadingText__c = 'Undefined Heading',
			SORDescriptionText__c = 'Undefined Desc',
			Category__c = null,
			SubCategory__c = null,
			DefaultLocation__c = 'UNK',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			SORRateCurrency__c = 10,
			Trade__c = 'General',
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c messageSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'X' + String.valueOf(Math.mod(System.now().getTime(), 1000000000L)),
			Message__c = 'Ignore in browse',
			RecordTypeId = messageRecordTypeId
		);
		insert new List<AHA_ERL_Code__c>{ groupedSor, undefinedSor, messageSor };

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = groupedSor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = undefinedSor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = messageSor.Id)
		};

		Test.startTest();
		List<AhaErlController.BrowseSORCat> browse = AhaErlController.getAllSORForBrowse(profileName);
		Test.stopTest();

		System.assertEquals(2, browse.size(),
			'Browse response should contain one defined and one UNDEFINED category group');

		Boolean foundDefined = false;
		Boolean foundUndefined = false;
		for (AhaErlController.BrowseSORCat cat : browse) {
			if (cat.category == 'Plumbing') {
				foundDefined = true;
				System.assertEquals(1, cat.subCategories.size(),
					'Defined category should include one subcategory group');
				System.assertEquals('Leaks', cat.subCategories[0].subCategory,
					'Subcategory label should be preserved for defined values');
				System.assertEquals(groupedSor.Id, cat.subCategories[0].sorList[0].id,
					'SOR should be grouped under its category/subcategory pair');
			}
			if (cat.category == 'UNDEFINED') {
				foundUndefined = true;
				System.assertEquals('UNDEFINED', cat.subCategories[0].subCategory,
					'Null subcategory should be converted to UNDEFINED');
				System.assertEquals(undefinedSor.Id, cat.subCategories[0].sorList[0].id,
					'Null category/subcategory SOR should still be returned');
			}
		}

		System.assert(foundDefined,
			'Expected defined category group to be present');
		System.assert(foundUndefined,
			'Expected UNDEFINED category group to be present');
	}

	@isTest
	static void getAllSORsForSearchReturnsSortedNonMessageCodes() {
		String profileName = 'SearchProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();

		AHA_ERL_Code__c sorB = new AHA_ERL_Code__c(
			SORCodeText__c = 'B000000001',
			SORHeadingText__c = 'Heading B',
			SORDescriptionText__c = 'Description B',
			DefaultLocation__c = 'KIT',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 3,
			SORRateCurrency__c = 30,
			Trade__c = 'Trade B',
			SORFullDescriptionLongText__c = 'Full B',
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c sorA = new AHA_ERL_Code__c(
			SORCodeText__c = 'A000000001',
			SORHeadingText__c = 'Heading A',
			SORDescriptionText__c = 'Description A',
			DefaultLocation__c = 'BAS',
			DefaultPriority__c = 'Urgent',
			DefaultQuantity__c = 1,
			SORRateCurrency__c = 10,
			Trade__c = 'Trade A',
			SORFullDescriptionLongText__c = 'Full A',
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c msg = new AHA_ERL_Code__c(
			SORCodeText__c = 'M000000001',
			Message__c = 'Message should be filtered',
			RecordTypeId = messageRecordTypeId
		);
		insert new List<AHA_ERL_Code__c>{ sorB, sorA, msg };

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = sorB.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = sorA.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = msg.Id)
		};

		Test.startTest();
		List<AhaErlController.AvailableSORs> response = AhaErlController.getAllSORsForSearch(profileName);
		Test.stopTest();

		System.assertEquals(2, response.size(),
			'Only non-message SOR codes should be returned');
		System.assertEquals('A000000001', response[0].sorCode,
			'Results should be ordered by SORCodeText ascending');
		System.assertEquals('B000000001', response[1].sorCode,
			'Results should include later code in sorted order');
		System.assertEquals(1, response[0].quantity,
			'Default quantity should map to AvailableSORs.quantity');
	}

	@isTest
	static void getSORProfileAssignmentsReturnsOnlyNullCategoryAssignments() {
		String sorCodeText = 'P000000001';
		AHA_ERL_Code_Profile__c p1 = new AHA_ERL_Code_Profile__c(
			Name = 'P1-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'P1-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c p2 = new AHA_ERL_Code_Profile__c(
			Name = 'P2-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'P2-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c p3 = new AHA_ERL_Code_Profile__c(
			Name = 'P3-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'P3-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ p1, p2, p3 };

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sor = new AHA_ERL_Code__c(
			SORCodeText__c = sorCodeText,
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			DefaultLocation__c = 'UNK',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			RecordTypeId = sorRecordTypeId
		);
		insert sor;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Filter Category',
			EditModeLabel__c = 'Filter Category',
			ExternalIdentifier__c = 'Filter-' + String.valueOf(System.now().getTime())
		);
		insert category;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = p1.Id, SORCode__c = sor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = p2.Id, SORCode__c = sor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = p3.Id, SORCode__c = sor.Id, SORCategory__c = category.Id)
		};

		Test.startTest();
		List<String> assignments = AhaErlController.getSORProfileAssignments(sorCodeText);
		Test.stopTest();

		System.assertEquals(2, assignments.size(),
			'Only junctions with null SORCategory__c should be returned');
		System.assert(assignments.contains(p1.Name),
			'First profile with direct SOR assignment should be included');
		System.assert(assignments.contains(p2.Name),
			'Second profile with direct SOR assignment should be included');
		System.assert(!assignments.contains(p3.Name),
			'Category-bound assignment should be excluded');
	}

	@isTest
	static void assignProfilestoSORReplacesAssignmentsForAdmin() {
		User adminUser = createUser('assignok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'Keep-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'Keep-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c addProfile = new AHA_ERL_Code_Profile__c(
			Name = 'Add-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'Add-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c removeProfile = new AHA_ERL_Code_Profile__c(
			Name = 'Remove-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'Remove-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ keepProfile, addProfile, removeProfile };

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sor = new AHA_ERL_Code__c(
			SORCodeText__c = 'R000000001',
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			DefaultLocation__c = 'UNK',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			RecordTypeId = sorRecordTypeId
		);
		insert sor;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = keepProfile.Id, SORCode__c = sor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = removeProfile.Id, SORCode__c = sor.Id)
		};

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.assignProfilestoSOR(
				new List<String>{ keepProfile.Name, addProfile.Name },
				sor.SORCodeText__c
			);
			Test.stopTest();
		}

		System.assertEquals('Successfully Assigned', result,
			'Admin should be able to replace SOR profile assignments');

		Set<String> resultingNames = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									FROM AHA_ERL_Junction__c
									WHERE SORCode__c = :sor.Id
									  AND SORCategory__c = null]) {
			resultingNames.add(j.SORProfile__r.Name);
		}

		System.assertEquals(2, resultingNames.size(),
			'Final assignments should match provided target list size');
		System.assert(resultingNames.contains(keepProfile.Name),
			'Existing profile in target list should remain assigned');
		System.assert(resultingNames.contains(addProfile.Name),
			'New profile in target list should be assigned');
		System.assert(!resultingNames.contains(removeProfile.Name),
			'Profiles omitted from target list should be removed');
	}

	@isTest
	static void assignProfilestoSORReturnsPermissionErrorForNonAdmin() {
		User nonAdminUser = createUser('assignna');
		String result;

		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.assignProfilestoSOR(new List<String>{ 'Any' }, 'A000000001');
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to assign profiles', result,
			'Non-admin users should not be able to assign SOR profiles');
	}

	@isTest
	static void editCategoryReturnsPermissionErrorForNonAdmin() {
		User nonAdminUser = createUser('editcatna');
		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Edit Denied',
			EditModeLabel__c = 'Edit Denied',
			ExternalIdentifier__c = 'EditDenied-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Map<String, String> details = new Map<String, String>{
			'recid' => category.Id,
			'label' => 'Updated Label',
			'editModeLabel' => 'Updated Edit',
			'imageFileText' => 'updated.jpg',
			'isGuided' => 'true'
		};

		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.editCategory(details, new List<String>());
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to edit this', result,
			'Non-admin users should not be able to edit categories');
	}

	@isTest
	static void editCategoryUpdatesFieldsAndSyncsProfilesForAdmin() {
		User adminUser = createUser('editcatok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c allProfile = new AHA_ERL_Code_Profile__c(
			Name = 'ALL',
			ExternalIdentifier__c = 'ALL'
		);
		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'KeepEC-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'KeepEC-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c removeProfile = new AHA_ERL_Code_Profile__c(
			Name = 'RemoveEC-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'RemoveEC-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ allProfile, keepProfile, removeProfile };

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Original Label',
			EditModeLabel__c = 'Original Edit',
			ImageFileText__c = 'old.jpg',
			Guided__c = false,
			ExternalIdentifier__c = 'EditCategory-' + String.valueOf(System.now().getTime())
		);
		insert category;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORCategory__c = category.Id, SORProfile__c = allProfile.Id),
			new AHA_ERL_Junction__c(SORCategory__c = category.Id, SORProfile__c = removeProfile.Id)
		};

		Map<String, String> details = new Map<String, String>{
			'recid' => category.Id,
			'label' => 'Updated Label',
			'editModeLabel' => 'Updated Edit',
			'imageFileText' => 'updated.jpg',
			'isGuided' => 'true'
		};

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.editCategory(details, new List<String>{ keepProfile.Name });
			Test.stopTest();
		}

		System.assertEquals('Successfully Updated', result,
			'Admin should be able to edit categories');

		AHA_ERL_Category__c updated = [SELECT Label__c, EditModeLabel__c, ImageFileText__c, Guided__c
									  FROM AHA_ERL_Category__c
									  WHERE Id = :category.Id
									  LIMIT 1];
		System.assertEquals('Updated Label', updated.Label__c,
			'Label should be updated');
		System.assertEquals('Updated Edit', updated.EditModeLabel__c,
			'Edit mode label should be updated');
		System.assertEquals('updated.jpg', updated.ImageFileText__c,
			'Image file should be updated');
		System.assertEquals(true, updated.Guided__c,
			'Guided flag should be updated');

		Set<String> profileNames = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									  FROM AHA_ERL_Junction__c
									  WHERE SORCategory__c = :category.Id]) {
			profileNames.add(j.SORProfile__r.Name);
		}
		System.assert(profileNames.contains('ALL'),
			'ALL profile junction should be preserved during sync');
		System.assert(profileNames.contains(keepProfile.Name),
			'Requested profile should be added during sync');
		System.assert(!profileNames.contains(removeProfile.Name),
			'Omitted non-ALL profile should be removed during sync');
	}

	@isTest
	static void saveCategoryGuidanceReturnsPermissionErrorForNonAdmin() {
		User nonAdminUser = createUser('guidena');
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = 'GuideProfile-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'GuideProfile-' + String.valueOf(System.now().getTime())
		);
		insert profile;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Guide Cat',
			EditModeLabel__c = 'Guide Cat',
			ExternalIdentifier__c = 'GuideCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.saveCategoryGuidance(category.Id, profile.Name, 'Body');
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to edit this', result,
			'Non-admin users should not be able to save guidance');
	}

	@isTest
	static void saveCategoryGuidanceCreatesAndUpdatesGuidance() {
		User adminUser = createUser('guideok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = 'GuideProfile-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'GuideProfile-' + String.valueOf(System.now().getTime())
		);
		insert profile;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Guide Cat',
			EditModeLabel__c = 'Guide Cat',
			ExternalIdentifier__c = 'GuideCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String createResult;
		String updateResult;
		System.runAs(adminUser) {
			Test.startTest();
			createResult = AhaErlController.saveCategoryGuidance(category.Id, profile.Name, 'Initial guidance');
			updateResult = AhaErlController.saveCategoryGuidance(category.Id, profile.Name, 'Updated guidance');
			Test.stopTest();
		}

		System.assertEquals('Successfully Updated', createResult,
			'First save should create guidance and junction');
		System.assertEquals('Successfully Updated', updateResult,
			'Second save should update existing guidance text');

		AHA_ERL_Category_Guidance_Junction__c junction = [SELECT Guidance__c
													 FROM AHA_ERL_Category_Guidance_Junction__c
													 WHERE Category__c = :category.Id
													   AND Profile__c = :profile.Id
													 LIMIT 1];
		System.assertNotEquals(null, junction.Guidance__c,
			'Guidance junction should be linked to a guidance record');

		AHA_ERL_Guidance__c guidance = [SELECT Guidance_Text__c
									  FROM AHA_ERL_Guidance__c
									  WHERE Id = :junction.Guidance__c
									  LIMIT 1];
		System.assertEquals('Updated guidance', guidance.Guidance_Text__c,
			'Guidance text should reflect the latest saved value');
	}

	@isTest
	static void saveCategoryGuidanceReturnsValidationErrors() {
		User adminUser = createUser('guideerr');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Guide Err Cat',
			EditModeLabel__c = 'Guide Err Cat',
			ExternalIdentifier__c = 'GuideErr-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String missingArgsResult;
		String missingProfileResult;
		System.runAs(adminUser) {
			Test.startTest();
			missingArgsResult = AhaErlController.saveCategoryGuidance(null, null, 'Body');
			missingProfileResult = AhaErlController.saveCategoryGuidance(
				category.Id,
				'NoSuchProfile-' + String.valueOf(System.now().getTime()),
				'Body'
			);
			Test.stopTest();
		}

		System.assertEquals('error: categoryId and profileName are required', missingArgsResult,
			'Missing required args should return explicit validation error');
		System.assertEquals('error: profile not found', missingProfileResult,
			'Unknown profile name should return profile-not-found error');
	}

	@isTest
	static void editMessageReturnsPermissionErrorForNonAdmin() {
		User nonAdminUser = createUser('editmsgna');
		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'MN' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Old Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.editMessage(messageCode.Id, 'New Message', new List<String>());
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to edit this', result,
			'Non-admin users should not be able to edit messages');
	}

	@isTest
	static void editMessageUpdatesTextAndSyncsProfilesForAdmin() {
		User adminUser = createUser('editmsgok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c allProfile = new AHA_ERL_Code_Profile__c(
			Name = 'ALL',
			ExternalIdentifier__c = 'ALL'
		);
		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'KeepEM-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'KeepEM-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c removeProfile = new AHA_ERL_Code_Profile__c(
			Name = 'RemoveEM-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'RemoveEM-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ allProfile, keepProfile, removeProfile };

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'ME' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Old Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORCode__c = messageCode.Id, SORProfile__c = allProfile.Id),
			new AHA_ERL_Junction__c(SORCode__c = messageCode.Id, SORProfile__c = removeProfile.Id)
		};

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.editMessage(messageCode.Id, 'New Message', new List<String>{ keepProfile.Name });
			Test.stopTest();
		}

		System.assertEquals('Successfully Updated', result,
			'Admin should be able to edit message text');

		AHA_ERL_Code__c refreshed = [SELECT Message__c
									 FROM AHA_ERL_Code__c
									 WHERE Id = :messageCode.Id
									 LIMIT 1];
		System.assertEquals('New Message', refreshed.Message__c,
			'Message body should be updated');

		Set<String> profileNames = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									  FROM AHA_ERL_Junction__c
									  WHERE SORCode__c = :messageCode.Id]) {
			profileNames.add(j.SORProfile__r.Name);
		}
		System.assert(profileNames.contains('ALL'),
			'ALL profile junction should be preserved when syncing message profiles');
		System.assert(profileNames.contains(keepProfile.Name),
			'Requested profile should be assigned to message');
		System.assert(!profileNames.contains(removeProfile.Name),
			'Omitted non-ALL profile should be removed from message assignments');
	}

	@isTest
	static void removeMessageFromCategoryReturnsPermissionErrorForNonAdmin() {
		User nonAdminUser = createUser('rmmsgna');

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'RM' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Remove Message Cat',
			EditModeLabel__c = 'Remove Message Cat',
			ExternalIdentifier__c = 'RmMsgCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		insert new AHA_ERL_Category_Junction__c(
			AHA_ERL_Category__c = category.Id,
			AHA_ERL_Code__c = messageCode.Id
		);

		String result;
		System.runAs(nonAdminUser) {
			Test.startTest();
			result = AhaErlController.removeMessageFromCategory(messageCode.Id, category.Id);
			Test.stopTest();
		}

		System.assertEquals('you do not have permission to remove this', result,
			'Non-admin users should not be able to remove messages from categories');
	}

	@isTest
	static void removeMessageFromCategoryRemovesJunctionForAdmin() {
		User adminUser = createUser('rmmsgok');
		assignAdminPermissionSet(adminUser);

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'RO' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Remove Message Cat',
			EditModeLabel__c = 'Remove Message Cat',
			ExternalIdentifier__c = 'RmMsgCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		insert new AHA_ERL_Category_Junction__c(
			AHA_ERL_Category__c = category.Id,
			AHA_ERL_Code__c = messageCode.Id
		);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.removeMessageFromCategory(messageCode.Id, category.Id);
			Test.stopTest();
		}

		System.assertEquals('Successfully Removed', result,
			'Admin should be able to remove message/category junctions');
		System.assertEquals(0, [SELECT COUNT()
								FROM AHA_ERL_Category_Junction__c
								WHERE AHA_ERL_Category__c = :category.Id
								  AND AHA_ERL_Code__c = :messageCode.Id],
			'Category junction should be deleted');
	}

	@isTest
	static void addSORtoCategoryPermissionAndSuccessPaths() {
		User nonAdminUser = createUser('addsorna');
		User adminUser = createUser('addsorok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Add SOR Cat',
			EditModeLabel__c = 'Add SOR Cat',
			ExternalIdentifier__c = 'AddSorCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sorCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'AS' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert sorCode;

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.addSORtoCategory(category.Id, sorCode.Id);
		}
		System.assertEquals('you do not have permission to add this', denied,
			'Non-admin users should not be able to add SORs to categories');

		String allowed;
		System.runAs(adminUser) {
			allowed = AhaErlController.addSORtoCategory(category.Id, sorCode.Id);
		}
		System.assertEquals('Successfully Added', allowed,
			'Admin should be able to add SOR/category junctions');
		System.assertEquals(1, [SELECT COUNT()
								FROM AHA_ERL_Category_Junction__c
								WHERE AHA_ERL_Category__c = :category.Id
								  AND AHA_ERL_Code__c = :sorCode.Id],
			'Success path should create one category junction');
	}

	@isTest
	static void getAllAvailableMessagesReturnsNullForNonAdminAndMessagesForAdmin() {
		User nonAdminUser = createUser('allmsgna');
		User adminUser = createUser('allmsgok');
		assignAdminPermissionSet(adminUser);

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();

		AHA_ERL_Code__c insertedMessage = new AHA_ERL_Code__c(
			SORCodeText__c = 'AM' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Visible message',
			RecordTypeId = messageRecordTypeId
		);
		AHA_ERL_Code__c insertedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'AN' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert new List<AHA_ERL_Code__c>{
			insertedMessage,
			insertedSor
		};

		List<AHA_ERL_Code__c> nonAdminResponse;
		List<AHA_ERL_Code__c> adminResponse;
		System.runAs(nonAdminUser) {
			nonAdminResponse = AhaErlController.getAllAvailableMessages();
		}
		System.runAs(adminUser) {
			adminResponse = AhaErlController.getAllAvailableMessages();
		}

		System.assertEquals(null, nonAdminResponse,
			'Non-admin users should receive null from getAllAvailableMessages');
		System.assertNotEquals(null, adminResponse,
			'Admin users should receive a message list');
		System.assert(adminResponse.size() >= 1,
			'Admin response should include at least one message record');
		Set<Id> adminIds = new Set<Id>();
		for (AHA_ERL_Code__c code : adminResponse) {
			adminIds.add(code.Id);
		}
		System.assert(adminIds.contains(insertedMessage.Id),
			'Admin response should include inserted message record');
		System.assert(!adminIds.contains(insertedSor.Id),
			'Admin response should exclude non-message SOR records');
	}

	@isTest
	static void addSORtoCategoryReturnsErrorForInvalidIdsAsAdmin() {
		User adminUser = createUser('addsorerr');
		assignAdminPermissionSet(adminUser);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.addSORtoCategory('not-an-id', 'not-an-id');
			Test.stopTest();
		}

		System.assert(result != null && result.startsWith('error:'),
			'Admin path should return error for invalid category/sor identifiers');
	}

	@isTest
	static void addExistingMessageToCategoryPermissionAndSuccessPaths() {
		User nonAdminUser = createUser('aemsgna');
		User adminUser = createUser('aemsgok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c allProfile = new AHA_ERL_Code_Profile__c(
			Name = 'ALL',
			ExternalIdentifier__c = 'ALL'
		);
		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'KeepAEM-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'KeepAEM-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c removeProfile = new AHA_ERL_Code_Profile__c(
			Name = 'RemoveAEM-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'RemoveAEM-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ allProfile, keepProfile, removeProfile };

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Add Existing Msg Cat',
			EditModeLabel__c = 'Add Existing Msg Cat',
			ExternalIdentifier__c = 'AEMCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'AE' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Existing Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORCode__c = messageCode.Id, SORProfile__c = allProfile.Id),
			new AHA_ERL_Junction__c(SORCode__c = messageCode.Id, SORProfile__c = removeProfile.Id)
		};

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.addExistingMessageToCategory(category.Id, messageCode.Id, new List<String>{ keepProfile.Name });
		}
		System.assertEquals('you do not have permission to add this', denied,
			'Non-admin users should not be able to add existing messages to a category');

		String allowed;
		System.runAs(adminUser) {
			allowed = AhaErlController.addExistingMessageToCategory(category.Id, messageCode.Id, new List<String>{ keepProfile.Name });
		}
		System.assertEquals('Successfully Added', allowed,
			'Admin should be able to add existing messages to a category');

		System.assertEquals(1, [SELECT COUNT()
								FROM AHA_ERL_Category_Junction__c
								WHERE AHA_ERL_Category__c = :category.Id
								  AND AHA_ERL_Code__c = :messageCode.Id],
			'Category junction should be created for the existing message');

		Set<String> profileNames = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									  FROM AHA_ERL_Junction__c
									  WHERE SORCode__c = :messageCode.Id]) {
			profileNames.add(j.SORProfile__r.Name);
		}
		System.assert(profileNames.contains('ALL'),
			'ALL profile junction should be retained during profile sync');
		System.assert(profileNames.contains(keepProfile.Name),
			'Requested profile should be assigned to the message');
		System.assert(!profileNames.contains(removeProfile.Name),
			'Omitted non-ALL profile should be removed');
	}

	@isTest
	static void addExistingMessageToCategoryReturnsErrorWhenProfileMissing() {
		User adminUser = createUser('aemsgerr');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'AEM Error Cat',
			EditModeLabel__c = 'AEM Error Cat',
			ExternalIdentifier__c = 'AEMErr-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'AX' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			Message__c = 'Existing Message',
			RecordTypeId = messageRecordTypeId
		);
		insert messageCode;

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.addExistingMessageToCategory(
				category.Id,
				messageCode.Id,
				new List<String>{ 'MissingProfile-' + String.valueOf(System.now().getTime()) }
			);
			Test.stopTest();
		}

		System.assert(result != null && result.startsWith('error:'),
			'Method should return error when requested profile does not exist');
	}

	@isTest
	static void addMessagetoCategoryPermissionAndSuccessPaths() {
		User nonAdminUser = createUser('addmsgna');
		User adminUser = createUser('addmsgok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c allProfile = new AHA_ERL_Code_Profile__c(
			Name = 'ALL',
			ExternalIdentifier__c = 'ALL'
		);
		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'KeepAMG-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'KeepAMG-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ allProfile, keepProfile };

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Add Message Cat',
			EditModeLabel__c = 'Add Message Cat',
			ExternalIdentifier__c = 'AMGCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String msgName = 'NM' + String.valueOf(Math.mod(System.now().getTime(), 100000000L));

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.addMessagetoCategory(category.Id, msgName, 'Body', new List<String>{ keepProfile.Name });
		}
		System.assertEquals('you do not have permission to add this', denied,
			'Non-admin users should not be able to create category messages');

		String allowed;
		System.runAs(adminUser) {
			allowed = AhaErlController.addMessagetoCategory(category.Id, msgName, 'Body', new List<String>{ keepProfile.Name });
		}
		System.assertEquals('Successfully Added', allowed,
			'Admin should be able to create and link messages');

		AHA_ERL_Code__c createdMessage = [SELECT Id, Message__c
									 FROM AHA_ERL_Code__c
									 WHERE SORCodeText__c = :msgName
									 LIMIT 1];
		System.assertEquals('Body', createdMessage.Message__c,
			'Created message should persist body text');

		System.assertEquals(1, [SELECT COUNT()
								FROM AHA_ERL_Category_Junction__c
								WHERE AHA_ERL_Category__c = :category.Id
								  AND AHA_ERL_Code__c = :createdMessage.Id],
			'Created message should be junctioned to the category');

		Set<String> profileNames = new Set<String>();
		for (AHA_ERL_Junction__c j : [SELECT SORProfile__r.Name
									  FROM AHA_ERL_Junction__c
									  WHERE SORCode__c = :createdMessage.Id]) {
			profileNames.add(j.SORProfile__r.Name);
		}
		System.assert(profileNames.contains(keepProfile.Name),
			'Provided profile should be assigned to the new message');
		System.assert(!profileNames.contains('ALL'),
			'ALL should not be auto-assigned by addMessagetoCategory without explicit input');
	}

	@isTest
	static void addMessagetoCategoryReturnsErrorForOversizedCode() {
		User adminUser = createUser('addmsgerr');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Code_Profile__c keepProfile = new AHA_ERL_Code_Profile__c(
			Name = 'KeepAMGE-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'KeepAMGE-' + String.valueOf(System.now().getTime())
		);
		insert keepProfile;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Add Message Err Cat',
			EditModeLabel__c = 'Add Message Err Cat',
			ExternalIdentifier__c = 'AMGErr-' + String.valueOf(System.now().getTime())
		);
		insert category;

		String tooLongMsgName = 'MSG12345678';

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.addMessagetoCategory(category.Id, tooLongMsgName, 'Body', new List<String>{ keepProfile.Name });
			Test.stopTest();
		}

		System.assert(result != null && result.startsWith('error:'),
			'Method should return error when message code exceeds field length');
	}

	@isTest
	static void removeSORfromCategoryHandlesNullPermissionAndSuccess() {
		User nonAdminUser = createUser('rmsorna');
		User adminUser = createUser('rmsorok');
		assignAdminPermissionSet(adminUser);

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Remove SOR Cat',
			EditModeLabel__c = 'Remove SOR Cat',
			ExternalIdentifier__c = 'RmSorCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sorCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'RS' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert sorCode;

		insert new AHA_ERL_Category_Junction__c(
			AHA_ERL_Category__c = category.Id,
			AHA_ERL_Code__c = sorCode.Id
		);

		String nullResult = AhaErlController.removeSORfromCategory(null, sorCode.Id);
		System.assertEquals('error: categoryId or sor is null', nullResult,
			'Null guard should fire before permission checks');

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.removeSORfromCategory(category.Id, sorCode.Id);
		}
		System.assertEquals('you do not have permission to remove this', denied,
			'Non-admin users should not be able to remove SOR/category junctions');

		String allowed;
		System.runAs(adminUser) {
			allowed = AhaErlController.removeSORfromCategory(category.Id, sorCode.Id);
		}
		System.assertEquals('Successfully Removed', allowed,
			'Admin should be able to remove SOR/category junctions');
		System.assertEquals(0, [SELECT COUNT()
								FROM AHA_ERL_Category_Junction__c
								WHERE AHA_ERL_Category__c = :category.Id
								  AND AHA_ERL_Code__c = :sorCode.Id],
			'Category junction should be deleted on success');
	}

	@isTest
	static void removeMessageFromCategoryReturnsSuccessForInvalidIdsAsAdmin() {
		User adminUser = createUser('rmmsgerr');
		assignAdminPermissionSet(adminUser);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.removeMessageFromCategory('not-an-id', 'not-an-id');
			Test.stopTest();
		}

		System.assertEquals('Successfully Removed', result,
			'Method currently treats invalid/non-matching ids as a no-op remove and returns success');
	}

	@isTest
	static void removeSORfromCategoryReturnsSuccessForInvalidIdsAsAdmin() {
		User adminUser = createUser('rmsorerr');
		assignAdminPermissionSet(adminUser);

		String result;
		System.runAs(adminUser) {
			Test.startTest();
			result = AhaErlController.removeSORfromCategory('not-an-id', 'not-an-id');
			Test.stopTest();
		}

		System.assertEquals('Successfully Removed', result,
			'Method currently treats invalid/non-matching ids as a no-op remove and returns success');
	}

	@isTest
	static void getCurrentJunctionedProfilesReturnsBySorOrCategory() {
		AHA_ERL_Code_Profile__c p1 = new AHA_ERL_Code_Profile__c(
			Name = 'JuncP1-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'JuncP1-' + String.valueOf(System.now().getTime())
		);
		AHA_ERL_Code_Profile__c p2 = new AHA_ERL_Code_Profile__c(
			Name = 'JuncP2-' + String.valueOf(System.now().getTime()),
			ExternalIdentifier__c = 'JuncP2-' + String.valueOf(System.now().getTime())
		);
		insert new List<AHA_ERL_Code_Profile__c>{ p1, p2 };

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Junction Category',
			EditModeLabel__c = 'Junction Category',
			ExternalIdentifier__c = 'JuncCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sor = new AHA_ERL_Code__c(
			SORCodeText__c = 'JP' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert sor;

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = p1.Id, SORCategory__c = category.Id),
			new AHA_ERL_Junction__c(SORProfile__c = p2.Id, SORCode__c = sor.Id)
		};

		Test.startTest();
		List<String> byCategory = AhaErlController.getCurrentJunctionedProfiles(category.Id, false);
		List<String> bySor = AhaErlController.getCurrentJunctionedProfiles(sor.Id, true);
		Test.stopTest();

		System.assertEquals(1, byCategory.size(),
			'Category query should return only category-bound junction profiles');
		System.assert(byCategory.contains(p1.Name),
			'Category query should include expected profile name');
		System.assertEquals(1, bySor.size(),
			'SOR query should return only SOR-bound junction profiles');
		System.assert(bySor.contains(p2.Name),
			'SOR query should include expected profile name');
	}

	@isTest
	static void logTrackingPersistsUsageTrackerViaFutureMethod() {
		String profileName = 'TrackProfile-' + String.valueOf(System.now().getTime());

		Test.startTest();
		AhaErlController.logTracking('A>B>C', '12.5', profileName, 'SOR1', 'GUIDED', 'COMPLETE');
		Test.stopTest();

		AHA_ERL_Usage_Tracker__c tracker = [SELECT PathTaken__c, TimeTaken__c, Profile__c, ItemSelected__c, Type__c, TrackerType__c
									 FROM AHA_ERL_Usage_Tracker__c
									 WHERE Profile__c = :profileName
									 ORDER BY CreatedDate DESC
									 LIMIT 1];
		System.assertEquals('A>B>C', tracker.PathTaken__c,
			'Path should be saved from logTracking input');
		System.assertEquals(12.5, tracker.TimeTaken__c,
			'Time should be saved as decimal from itime input');
		System.assertEquals('SOR1', tracker.ItemSelected__c,
			'Item should be saved from logTracking input');
		System.assertEquals('GUIDED', tracker.Type__c,
			'Type should be saved from logTracking input');
		System.assertEquals('COMPLETE', tracker.TrackerType__c,
			'TrackerType should be saved from logTracking input');
	}

	@isTest
	static void logTrackingAsyncPersistsUsageTrackerDirectly() {
		String profileName = 'AsyncProfile-' + String.valueOf(System.now().getTime());

		Test.startTest();
		AhaErlController.logTrackingAsync('X>Y', '3', profileName, 'ITEM', 'DIAGNOSTIC', 'PARTIAL');
		Test.stopTest();

		AHA_ERL_Usage_Tracker__c tracker = [SELECT PathTaken__c, TimeTaken__c, Profile__c, ItemSelected__c, Type__c, TrackerType__c
									 FROM AHA_ERL_Usage_Tracker__c
									 WHERE Profile__c = :profileName
									 ORDER BY CreatedDate DESC
									 LIMIT 1];
		System.assertEquals('X>Y', tracker.PathTaken__c,
			'Path should be saved from logTrackingAsync input');
		System.assertEquals(3, tracker.TimeTaken__c,
			'Time should be saved from direct async call input');
		System.assertEquals('ITEM', tracker.ItemSelected__c,
			'Item should be saved from direct async call input');
	}

	@isTest
	static void getAllSORsWithAssignmentMarksSelectedByProfileJunction() {
		String profileName = 'AssignProfile-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		AHA_ERL_Category__c category = new AHA_ERL_Category__c(
			Label__c = 'Assignment Category',
			EditModeLabel__c = 'Assignment Category',
			ExternalIdentifier__c = 'AssignCat-' + String.valueOf(System.now().getTime())
		);
		insert category;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		Id messageRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('Message').getRecordTypeId();
		AHA_ERL_Code__c selectedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'AA00000001',
			SORHeadingText__c = 'Heading A',
			SORDescriptionText__c = 'Description A',
			DefaultLocation__c = 'KIT',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c unselectedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'AB00000001',
			SORHeadingText__c = 'Heading B',
			SORDescriptionText__c = 'Description B',
			DefaultLocation__c = 'UNK',
			DefaultPriority__c = 'Routine',
			DefaultQuantity__c = 1,
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c messageCode = new AHA_ERL_Code__c(
			SORCodeText__c = 'AC00000001',
			Message__c = 'Filtered message',
			RecordTypeId = messageRecordTypeId
		);
		insert new List<AHA_ERL_Code__c>{ selectedSor, unselectedSor, messageCode };

		insert new List<AHA_ERL_Junction__c>{
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = selectedSor.Id),
			new AHA_ERL_Junction__c(SORProfile__c = profile.Id, SORCode__c = unselectedSor.Id, SORCategory__c = category.Id)
		};

		Test.startTest();
		List<AhaErlController.AvailableSORs> response = AhaErlController.getAllSORsWithAssignment(profileName);
		Test.stopTest();

		Map<Id, AhaErlController.AvailableSORs> byId = new Map<Id, AhaErlController.AvailableSORs>();
		for (AhaErlController.AvailableSORs row : response) {
			byId.put(row.id, row);
		}

		System.assert(byId.containsKey(selectedSor.Id),
			'Non-message selected SOR should be included in response');
		System.assert(byId.containsKey(unselectedSor.Id),
			'Non-message unselected SOR should be included in response');
		System.assert(!byId.containsKey(messageCode.Id),
			'Message record type should be excluded from assignment list');
		System.assertEquals(true, byId.get(selectedSor.Id).selected,
			'Direct profile/SOR junction should mark SOR as selected');
		System.assertEquals(false, byId.get(unselectedSor.Id).selected,
			'Category-bound junction should not mark SOR as selected');
	}

	@isTest
	static void addSORAssignmentHandlesPermissionSuccessAndInvalidProfile() {
		User nonAdminUser = createUser('addsassignna');
		User adminUser = createUser('addsassignok');
		assignAdminPermissionSet(adminUser);

		String profileName = 'AddAssign-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c sor = new AHA_ERL_Code__c(
			SORCodeText__c = 'AD' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading',
			SORDescriptionText__c = 'Description',
			RecordTypeId = sorRecordTypeId
		);
		insert sor;

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.addSORAssignment(profileName, sor.Id);
		}
		System.assertEquals('error: you do not have permission to add this assignment', denied,
			'Non-admin users should not be able to add SOR assignments');

		String allowed;
		System.runAs(adminUser) {
			allowed = AhaErlController.addSORAssignment(profileName, sor.Id);
		}
		System.assertEquals('Successfully Assigned', allowed,
			'Admin users should be able to add SOR assignments');
		System.assertEquals(1, [SELECT COUNT()
								FROM AHA_ERL_Junction__c
								WHERE SORProfile__c = :profile.Id
								  AND SORCode__c = :sor.Id
								  AND SORCategory__c = null],
			'Add assignment should insert direct profile/SOR junction');

		String invalidProfileResult;
		System.runAs(adminUser) {
			invalidProfileResult = AhaErlController.addSORAssignment('Missing-' + String.valueOf(System.now().getTime()), sor.Id);
		}
		System.assert(invalidProfileResult != null && invalidProfileResult.startsWith('error:'),
			'Method should return error when profile cannot be resolved');
	}

	@isTest
	static void removeSORAssignmentHandlesPermissionSuccessAndMissingAssignment() {
		User nonAdminUser = createUser('rmsassignna');
		User adminUser = createUser('rmsassignok');
		assignAdminPermissionSet(adminUser);

		String profileName = 'RemoveAssign-' + String.valueOf(System.now().getTime());
		AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
			Name = profileName,
			ExternalIdentifier__c = profileName
		);
		insert profile;

		Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName()
			.get('SORCode').getRecordTypeId();
		AHA_ERL_Code__c assignedSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'RA' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading A',
			SORDescriptionText__c = 'Description A',
			RecordTypeId = sorRecordTypeId
		);
		AHA_ERL_Code__c missingSor = new AHA_ERL_Code__c(
			SORCodeText__c = 'RB' + String.valueOf(Math.mod(System.now().getTime(), 100000000L)),
			SORHeadingText__c = 'Heading B',
			SORDescriptionText__c = 'Description B',
			RecordTypeId = sorRecordTypeId
		);
		insert new List<AHA_ERL_Code__c>{ assignedSor, missingSor };

		insert new AHA_ERL_Junction__c(
			SORProfile__c = profile.Id,
			SORCode__c = assignedSor.Id
		);

		String denied;
		System.runAs(nonAdminUser) {
			denied = AhaErlController.removeSORAssignment(profileName, assignedSor.Id);
		}
		System.assertEquals('error: you do not have permission to remove this assignment', denied,
			'Non-admin users should not be able to remove SOR assignments');

		String removed;
		System.runAs(adminUser) {
			removed = AhaErlController.removeSORAssignment(profileName, assignedSor.Id);
		}
		System.assertEquals('Successfully Removed', removed,
			'Admin users should be able to remove SOR assignments');
		System.assertEquals(0, [SELECT COUNT()
								FROM AHA_ERL_Junction__c
								WHERE SORProfile__c = :profile.Id
								  AND SORCode__c = :assignedSor.Id],
			'Assignment junction should be deleted on success');

		String missingAssignmentResult;
		System.runAs(adminUser) {
			missingAssignmentResult = AhaErlController.removeSORAssignment(profileName, missingSor.Id);
		}
		System.assertEquals('Successfully Removed', missingAssignmentResult,
			'Method currently treats a missing assignment as a no-op remove and returns success');
	}

}

