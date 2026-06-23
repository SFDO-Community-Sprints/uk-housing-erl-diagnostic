---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->


## Schema

```mermaid
graph TD
AHA_ERL_Junction__c["AHA-ERL-Profile Junction"]:::customObject
click AHA_ERL_Junction__c "/objects/AHA_ERL_Junction__c/"
AHA_ERL_Code__c["AHA-ERL Code"]:::mainObject
click AHA_ERL_Code__c "/objects/AHA_ERL_Code__c/"
AHA_ERL_Category_Junction__c["AHA-ERL-Category Junction"]:::customObject
click AHA_ERL_Category_Junction__c "/objects/AHA_ERL_Category_Junction__c/"

AHA_ERL_Junction__c -->|SORCode__c| AHA_ERL_Code__c
AHA_ERL_Category_Junction__c ==>|AHA_ERL_Code__c| AHA_ERL_Code__c

classDef object fill:#D6E9FF,stroke:#0070D2,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObject fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObjectManaged fill:#FFD8B2,stroke:#CC5500,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainObject fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;
linkStyle 1 stroke:#4C9F70,stroke-width:4px;
linkStyle 0 stroke:#A6A6A6,stroke-width:2px;

```


<!-- Object description -->

## Fields

| Name | Label | Type | Description |
| :-------- | :---- | :--: | :---------- | 
| Category__c | Category | Text | undefined |
| CategoryPicklist__c | Category | Picklist | undefined |
| DefaultLocation__c | Default Location | Text | undefined |
| DefaultPriority__c | Default Priority | Text | undefined |
| DefaultQuantity__c | Default Quantity | Number | undefined |
| Message__c | Message | Html | Messages are used for Message Sor Code record types, this message will be displayed on the SOR selector instead of a selectable SOR. |
| SORCodeText__c | SOR Code | Text | undefined |
| SORDescriptionText__c | SOR Description | Text | undefined |
| SORFullDescriptionLongText__c | SOR Full Description | LongTextArea | undefined |
| SORHeadingText__c | SOR Heading | Text | undefined |
| SORRateCurrency__c | SOR Rate | Currency | undefined |
| SubCategory__c | Sub-Category | Text | undefined |
| SubCategoryPicklist__c | Sub-Category | Picklist | undefined |
| Trade__c | Trade | Text | undefined |






## Related Apex Classes

| Apex Class | Type |
| :----      | :--: | 
| [AhaErlCategoryJunctionHelperTest](../apex/AhaErlCategoryJunctionHelperTest.md) | Test |
| [AhaErlController](../apex/AhaErlController.md) | Lightning Controller |
| [AhaErlHierarchyController](../apex/AhaErlHierarchyController.md) | Lightning Controller |
| [AhaErlHierarchyControllerTest](../apex/AhaErlHierarchyControllerTest.md) | Test |
| [AhaErlSeedDataController](../apex/AhaErlSeedDataController.md) | Lightning Controller |
| [AhaErlSeedDataControllerTest](../apex/AhaErlSeedDataControllerTest.md) | Test |


## Related Lightning Pages

| Lightning Page | Type |
| :----      | :--: | 
| [AHA_ERL_Code_Record_Page](../pages/AHA_ERL_Code_Record_Page.md) |  Record Page |




## Related Permission Sets

| Permission Set | User License |
| :----      | :--: | 
| [ERL_Full_Access](../permissionsets/ERL_Full_Access.md) | None |




[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
