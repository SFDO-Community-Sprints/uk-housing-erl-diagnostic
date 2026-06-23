---
hide:
  - path
---

# AhaErlHierarchyControllerTest Class

`ISTEST`

Unit tests for AhaErlHierarchyController covering hierarchy data retrieval, 
profile options, category path building, accessibility checks, and the closeup filter.

## Class Diagram

```mermaid
graph TD
  AhaErlHierarchyControllerTest["AhaErlHierarchyControllerTest"]:::mainApexClass
  click AhaErlHierarchyControllerTest "/objects/AhaErlHierarchyControllerTest/"
  AhaErlHierarchyController["AhaErlHierarchyController"]:::apexClass
  click AhaErlHierarchyController "/apex/AhaErlHierarchyController/"

  AhaErlHierarchyControllerTest --> AhaErlHierarchyController



classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
```

<!-- Apex description -->

## Apex Code

```java
/**
 * @description Unit tests for AhaErlHierarchyController covering hierarchy data retrieval,
 * profile options, category path building, accessibility checks, and the closeup filter.
 */
@isTest
public class AhaErlHierarchyControllerTest {
    
    @testSetup
    static void setup() {
        // Create test profile
        AHA_ERL_Code_Profile__c profile = new AHA_ERL_Code_Profile__c(
            Name = 'Test Profile',
            Description__c = 'Test Description',
            ExternalIdentifier__c = 'TestProfile'
        );
        insert profile;
        
        // Create test categories
        AHA_ERL_Category__c rootCategory = new AHA_ERL_Category__c(
            Label__c = 'Root Category',
            EditModeLabel__c = 'Root',
            ExternalIdentifier__c = 'RootCat'
        );
        insert rootCategory;
        
        AHA_ERL_Category__c childCategory = new AHA_ERL_Category__c(
            Label__c = 'Child Category',
            EditModeLabel__c = 'Child',
            ParentCategoryLookup__c = rootCategory.Id,
            ExternalIdentifier__c = 'ChildCat'
        );
        insert childCategory;
        
        // Create test SOR codes
        Id sorRecordTypeId = Schema.SObjectType.AHA_ERL_Code__c.getRecordTypeInfosByDeveloperName().get('SORCode').getRecordTypeId();
        
        AHA_ERL_Code__c sor1 = new AHA_ERL_Code__c(
            SORCodeText__c = 'TEST001',
            SORHeadingText__c = 'Test SOR 1',
            SORDescriptionText__c = 'Test Description 1',
            RecordTypeId = sorRecordTypeId
        );
        insert sor1;
        
        AHA_ERL_Code__c sor2 = new AHA_ERL_Code__c(
            SORCodeText__c = 'TEST002',
            SORHeadingText__c = 'Test SOR 2',
            SORDescriptionText__c = 'Test Description 2',
            RecordTypeId = sorRecordTypeId
        );
        insert sor2;
        
        // Create SOR to Category junctions
        AHA_ERL_Category_Junction__c catJunction1 = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Code__c = sor1.Id,
            AHA_ERL_Category__c = rootCategory.Id
        );
        insert catJunction1;
        
        AHA_ERL_Category_Junction__c catJunction2 = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Code__c = sor1.Id,
            AHA_ERL_Category__c = childCategory.Id
        );
        insert catJunction2;
        
        AHA_ERL_Category_Junction__c catJunction3 = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Code__c = sor2.Id,
            AHA_ERL_Category__c = childCategory.Id
        );
        insert catJunction3;
        
        // Create SOR to Profile junctions
        AHA_ERL_Junction__c sorJunction1 = new AHA_ERL_Junction__c(
            SORCode__c = sor1.Id,
            SORProfile__c = profile.Id
        );
        insert sorJunction1;
        
        AHA_ERL_Junction__c sorJunction2 = new AHA_ERL_Junction__c(
            SORCode__c = sor2.Id,
            SORProfile__c = profile.Id
        );
        insert sorJunction2;
        
        // Create Category to Profile junctions
        AHA_ERL_Junction__c catProfileJunction1 = new AHA_ERL_Junction__c(
            SORCategory__c = rootCategory.Id,
            SORProfile__c = profile.Id
        );
        insert catProfileJunction1;
        
        AHA_ERL_Junction__c catProfileJunction2 = new AHA_ERL_Junction__c(
            SORCategory__c = childCategory.Id,
            SORProfile__c = profile.Id
        );
        insert catProfileJunction2;
    }
    
    @isTest
    static void testGetSORHierarchyData() {
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', false);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return at least one record');
        
        // Verify data structure
        AhaErlHierarchyController.SORHierarchyData firstRecord = results[0];
        System.assertNotEquals(null, firstRecord.sorId, 'SOR ID should not be null');
        System.assertNotEquals(null, firstRecord.sorCode, 'SOR Code should not be null');
        System.assertNotEquals(null, firstRecord.categoryPath, 'Category path should not be null');
        System.assertNotEquals(null, firstRecord.isAccessible, 'Accessible flag should not be null');
    }
    
    @isTest
    static void testGetSORHierarchyDataInvalidProfile() {
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Nonexistent Profile', false);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for invalid profile');
    }
    
    @isTest
    static void testGetProfileOptions() {
        Test.startTest();
        List<Map<String, String>> options = AhaErlHierarchyController.getProfileOptions();
        Test.stopTest();
        
        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should return at least one profile option');
        
        // Verify structure
        Map<String, String> firstOption = options[0];
        System.assert(firstOption.containsKey('label'), 'Option should have label key');
        System.assert(firstOption.containsKey('value'), 'Option should have value key');
    }
    
    @isTest
    static void testBuildCategoryPathWithMultipleLevels() {
        // This tests the recursive path building
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', true);
        Test.stopTest();
        
        // Find a record with child category path
        Boolean foundChildPath = false;
        for (AhaErlHierarchyController.SORHierarchyData data : results) {
            if (data.categoryPath.contains('>')) {
                foundChildPath = true;
                System.assert(data.categoryPath.contains('Root Category'), 'Path should contain root category');
                System.assert(data.categoryPath.contains('Child Category'), 'Path should contain child category');
                break;
            }
        }
        
        System.assert(foundChildPath, 'Should find at least one multi-level category path');
    }
    
    @isTest
    static void testAccessibilityCheck() {
        // Create a category not assigned to profile
        AHA_ERL_Category__c inaccessibleCategory = new AHA_ERL_Category__c(
            Label__c = 'Inaccessible Category',
            EditModeLabel__c = 'Inaccessible',
            ExternalIdentifier__c = 'InaccessibleCat'
        );
        insert inaccessibleCategory;
        
        // Get an existing SOR
        AHA_ERL_Code__c existingSor = [SELECT Id FROM AHA_ERL_Code__c LIMIT 1];
        
        // Create junction to inaccessible category
        AHA_ERL_Category_Junction__c catJunction = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Code__c = existingSor.Id,
            AHA_ERL_Category__c = inaccessibleCategory.Id
        );
        insert catJunction;
        
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', false);
        Test.stopTest();
        
        // Find the inaccessible path
        Boolean foundInaccessiblePath = false;
        for (AhaErlHierarchyController.SORHierarchyData data : results) {
            if (data.categoryPath.contains('Inaccessible Category')) {
                foundInaccessiblePath = true;
                System.assertEquals(false, data.isAccessible, 'Path should be marked as inaccessible');
                break;
            }
        }
        
        System.assert(foundInaccessiblePath, 'Should find the inaccessible path');
    }
    
    @isTest
    static void testEmptyCategoryPath() {
        // Test with null category map
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', false);
        Test.stopTest();
        
        // All results should have a category path (even if it's 'Unknown')
        for (AhaErlHierarchyController.SORHierarchyData data : results) {
            System.assertNotEquals(null, data.categoryPath, 'Category path should not be null');
            System.assertNotEquals('', data.categoryPath, 'Category path should not be empty');
        }
    }
    
    @isTest
    static void testMultipleSORsInSameCategory() {
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> results = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', false);
        Test.stopTest();
        
        // Should have multiple records for the child category
        Integer childCategoryCount = 0;
        for (AhaErlHierarchyController.SORHierarchyData data : results) {
            if (data.categoryPath.contains('Child Category')) {
                childCategoryCount++;
            }
        }
        
        System.assert(childCategoryCount >= 2, 'Should have at least 2 SORs in child category');
    }
    
    @isTest
    static void testIncludeCloseups() {
        // Create a closeup category
        Id closeupRecordTypeId = Schema.SObjectType.AHA_ERL_Category__c.getRecordTypeInfosByDeveloperName().get('RepairLocationCloseup').getRecordTypeId();
        
        AHA_ERL_Category__c closeupCategory = new AHA_ERL_Category__c(
            Label__c = 'Closeup Category',
            EditModeLabel__c = 'Closeup',
            ExternalIdentifier__c = 'CloseupCat',
            RecordTypeId = closeupRecordTypeId
        );
        insert closeupCategory;
        
        // Get existing profile
        AHA_ERL_Code_Profile__c profile = [SELECT Id FROM AHA_ERL_Code_Profile__c WHERE Name = 'Test Profile' LIMIT 1];
        
        // Create junction
        AHA_ERL_Junction__c catProfileJunction = new AHA_ERL_Junction__c(
            SORCategory__c = closeupCategory.Id,
            SORProfile__c = profile.Id
        );
        insert catProfileJunction;
        
        Test.startTest();
        List<AhaErlHierarchyController.SORHierarchyData> resultsWithCloseup = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', true);
        List<AhaErlHierarchyController.SORHierarchyData> resultsWithoutCloseup = 
            AhaErlHierarchyController.getSORHierarchyData('Test Profile', false);
        Test.stopTest();
        
        System.assertNotEquals(null, resultsWithCloseup, 'Results with closeup should not be null');
        System.assertNotEquals(null, resultsWithoutCloseup, 'Results without closeup should not be null');
    }
}
```

## Methods
### `setup()`

`TESTSETUP`

#### Signature
```apex
private static void setup()
```

#### Return Type
**void**

---

### `testGetSORHierarchyData()`

`ISTEST`

#### Signature
```apex
private static void testGetSORHierarchyData()
```

#### Return Type
**void**

---

### `testGetSORHierarchyDataInvalidProfile()`

`ISTEST`

#### Signature
```apex
private static void testGetSORHierarchyDataInvalidProfile()
```

#### Return Type
**void**

---

### `testGetProfileOptions()`

`ISTEST`

#### Signature
```apex
private static void testGetProfileOptions()
```

#### Return Type
**void**

---

### `testBuildCategoryPathWithMultipleLevels()`

`ISTEST`

#### Signature
```apex
private static void testBuildCategoryPathWithMultipleLevels()
```

#### Return Type
**void**

---

### `testAccessibilityCheck()`

`ISTEST`

#### Signature
```apex
private static void testAccessibilityCheck()
```

#### Return Type
**void**

---

### `testEmptyCategoryPath()`

`ISTEST`

#### Signature
```apex
private static void testEmptyCategoryPath()
```

#### Return Type
**void**

---

### `testMultipleSORsInSameCategory()`

`ISTEST`

#### Signature
```apex
private static void testMultipleSORsInSameCategory()
```

#### Return Type
**void**

---

### `testIncludeCloseups()`

`ISTEST`

#### Signature
```apex
private static void testIncludeCloseups()
```

#### Return Type
**void**