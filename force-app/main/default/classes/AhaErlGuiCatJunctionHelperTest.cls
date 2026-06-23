@IsTest
private class AhaErlGuiCatJunctionHelperTest {

    @TestSetup
    static void setup() {
        AHA_ERL_Category__c cat = new AHA_ERL_Category__c(
            Name = 'Test Category',
            ExternalIdentifier__c = 'SETUP-CAT-001'
        );
        insert cat;

        AHA_ERL_Guidance__c guidance = new AHA_ERL_Guidance__c(
            Name = 'Test Guidance'
        );
        insert guidance;

        AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
            Name = 'Test Profile',
            ExternalIdentifier__c = 'SETUP-PROF-001'
        );
        insert profile;
    }

    @IsTest
    static void insertSetsExternalIdentifier() {
        AHA_ERL_Category__c cat = [SELECT Id FROM AHA_ERL_Category__c LIMIT 1];
        AHA_ERL_Guidance__c guidance = [SELECT Id FROM AHA_ERL_Guidance__c LIMIT 1];
        AHA_ERL_Code_Profile__c profile = [SELECT Id FROM AHA_ERL_Code_Profile__c LIMIT 1];

        AHA_ERL_Category_Guidance_Junction__c junction = new AHA_ERL_Category_Guidance_Junction__c(
            Category__c = cat.Id,
            Guidance__c = guidance.Id,
            Profile__c = profile.Id
        );

        Test.startTest();
        insert junction;
        Test.stopTest();

        AHA_ERL_Category_Guidance_Junction__c result = [
            SELECT ExternalIdentifier__c FROM AHA_ERL_Category_Guidance_Junction__c WHERE Id = :junction.Id
        ];
        System.assert(
            result.ExternalIdentifier__c != null,
            'ExternalIdentifier__c should be set after insert'
        );
        System.assert(
            result.ExternalIdentifier__c.startsWith('AHAERLGCJ-'),
            'ExternalIdentifier__c should start with AHAERLGCJ-'
        );
        System.assert(
            result.ExternalIdentifier__c.contains(junction.Id),
            'ExternalIdentifier__c should include the record Id'
        );
    }

    @IsTest
    static void doesNotOverwriteExistingExternalIdentifier() {
        AHA_ERL_Category__c cat = [SELECT Id FROM AHA_ERL_Category__c LIMIT 1];
        AHA_ERL_Guidance__c guidance = [SELECT Id FROM AHA_ERL_Guidance__c LIMIT 1];
        AHA_ERL_Code_Profile__c profile = [SELECT Id FROM AHA_ERL_Code_Profile__c LIMIT 1];

        AHA_ERL_Category_Guidance_Junction__c junction = new AHA_ERL_Category_Guidance_Junction__c(
            Category__c = cat.Id,
            Guidance__c = guidance.Id,
            Profile__c = profile.Id,
            ExternalIdentifier__c = 'PRE-EXISTING-VALUE'
        );
        insert junction;

        Test.startTest();
        AhaErlGuiCatJunctionHelper.updateExternalIdentifier(new Set<Id>{ junction.Id });
        Test.stopTest();

        AHA_ERL_Category_Guidance_Junction__c result = [
            SELECT ExternalIdentifier__c FROM AHA_ERL_Category_Guidance_Junction__c WHERE Id = :junction.Id
        ];
        System.assertEquals(
            'PRE-EXISTING-VALUE',
            result.ExternalIdentifier__c,
            'Should not overwrite an already-set ExternalIdentifier__c'
        );
    }
}