---
hide:
  - path
---

# AhaErlCategoryJunctionHelperTest Class

`ISTEST`

## Class Diagram

```mermaid
graph TD
  AhaErlCategoryJunctionHelperTest["AhaErlCategoryJunctionHelperTest"]:::mainApexClass
  click AhaErlCategoryJunctionHelperTest "/objects/AhaErlCategoryJunctionHelperTest/"
  AhaErlCategoryJunctionHelper["AhaErlCategoryJunctionHelper"]:::apexClass
  click AhaErlCategoryJunctionHelper "/apex/AhaErlCategoryJunctionHelper/"

  AhaErlCategoryJunctionHelperTest --> AhaErlCategoryJunctionHelper



classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
```

<!-- Apex description -->

## Apex Code

```java
@IsTest
private class AhaErlCategoryJunctionHelperTest {

    @TestSetup
    static void setup() {
        AHA_ERL_Category__c cat = new AHA_ERL_Category__c(
            Name = 'Test Category',
            ExternalIdentifier__c = 'SETUP-CAT-001'
        );
        insert cat;

        AHA_ERL_Code__c code = new AHA_ERL_Code__c(
            SORCodeText__c = 'SETUP-CODE-001'
        );
        insert code;
    }

    @IsTest
    static void insertSetsExternalIdentifier() {
        AHA_ERL_Category__c cat = [SELECT Id FROM AHA_ERL_Category__c LIMIT 1];
        AHA_ERL_Code__c code = [SELECT Id FROM AHA_ERL_Code__c LIMIT 1];

        AHA_ERL_Category_Junction__c junction = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Category__c = cat.Id,
            AHA_ERL_Code__c = code.Id
        );

        Test.startTest();
        insert junction;
        Test.stopTest();

        AHA_ERL_Category_Junction__c result = [
            SELECT ExternalIdentifier__c FROM AHA_ERL_Category_Junction__c WHERE Id = :junction.Id
        ];
        System.assert(
            result.ExternalIdentifier__c != null,
            'ExternalIdentifier__c should be set after insert'
        );
        System.assert(
            result.ExternalIdentifier__c.startsWith('AHAERLCJ-'),
            'ExternalIdentifier__c should start with AHAERLCJ-'
        );
        System.assert(
            result.ExternalIdentifier__c.contains(junction.Id),
            'ExternalIdentifier__c should include the record Id'
        );
    }

    @IsTest
    static void doesNotOverwriteExistingExternalIdentifier() {
        AHA_ERL_Category__c cat = [SELECT Id FROM AHA_ERL_Category__c LIMIT 1];
        AHA_ERL_Code__c code = [SELECT Id FROM AHA_ERL_Code__c LIMIT 1];

        AHA_ERL_Category_Junction__c junction = new AHA_ERL_Category_Junction__c(
            AHA_ERL_Category__c = cat.Id,
            AHA_ERL_Code__c = code.Id,
            ExternalIdentifier__c = 'PRE-EXISTING-VALUE'
        );
        insert junction;

        Test.startTest();
        AhaErlCategoryJunctionHelper.updateExternalIdentifier(new Set<Id>{ junction.Id });
        Test.stopTest();

        AHA_ERL_Category_Junction__c result = [
            SELECT ExternalIdentifier__c FROM AHA_ERL_Category_Junction__c WHERE Id = :junction.Id
        ];
        System.assertEquals(
            'PRE-EXISTING-VALUE',
            result.ExternalIdentifier__c,
            'Should not overwrite an already-set ExternalIdentifier__c'
        );
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

### `insertSetsExternalIdentifier()`

`ISTEST`

#### Signature
```apex
private static void insertSetsExternalIdentifier()
```

#### Return Type
**void**

---

### `doesNotOverwriteExistingExternalIdentifier()`

`ISTEST`

#### Signature
```apex
private static void doesNotOverwriteExistingExternalIdentifier()
```

#### Return Type
**void**