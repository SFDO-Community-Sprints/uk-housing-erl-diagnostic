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
AHA_ERL_Category__c["AHA-ERL Category"]:::mainObject
click AHA_ERL_Category__c "/objects/AHA_ERL_Category__c/"
AHA_ERL_Category_Junction__c["AHA-ERL-Category Junction"]:::customObject
click AHA_ERL_Category_Junction__c "/objects/AHA_ERL_Category_Junction__c/"
AHA_ERL_Category_Guidance_Junction__c["AHA-ERL Category-Guidance Junction"]:::customObject
click AHA_ERL_Category_Guidance_Junction__c "/objects/AHA_ERL_Category_Guidance_Junction__c/"

AHA_ERL_Junction__c -->|SORCategory__c| AHA_ERL_Category__c
AHA_ERL_Category__c -->|RedirectToLookup__c| AHA_ERL_Category__c
AHA_ERL_Category__c -->|ParentCategoryLookup__c| AHA_ERL_Category__c
AHA_ERL_Category_Junction__c ==>|AHA_ERL_Category__c| AHA_ERL_Category__c
AHA_ERL_Category_Guidance_Junction__c ==>|Category__c| AHA_ERL_Category__c

classDef object fill:#D6E9FF,stroke:#0070D2,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObject fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObjectManaged fill:#FFD8B2,stroke:#CC5500,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainObject fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;
linkStyle 3,4 stroke:#4C9F70,stroke-width:4px;
linkStyle 0,1,2 stroke:#A6A6A6,stroke-width:2px;

```


<!-- Object description -->

## Fields

| Name | Label | Type | Description |
| :-------- | :---- | :--: | :---------- | 
| Category__c | Category | Picklist | undefined |
| EditModeLabel__c | Edit Mode Label | Text | undefined |
| ExternalIdentifier__c | External Identifier | Text | undefined |
| Full_Category__c | Full Category | Text | undefined |
| Full_Category_Layout__c | Full Category (Layout) | Text | undefined |
| FullLabel__c | Full Label | Text | undefined |
| Guided__c | Guided | Checkbox | undefined |
| HasParent__c | Has Parent | Checkbox | undefined |
| ImageFileText__c | Image File | Text | The location of the image file in the SOR Picker Static Resource zip file. |
| ItemPicklist__c | Item | Picklist | undefined |
| Label__c | Label | Text | The label to appear on the Category/Item/List |
| Layout_Left__c | Layout Left | Text | undefined |
| Layout_Top__c | Layout Top | Text | undefined |
| ParentCategoryLookup__c | Parent Category | Lookup | undefined |
| ParentExternalIdentifier__c | Parent External Identifier | Text | undefined |
| RecordTypeName__c | Record Type Name | Text | undefined |
| RedirectToLookup__c | Redirect To | Lookup | undefined |
| Reporting__c | Reporting | Checkbox | undefined |
| Sub_Item__c | Sub-Item | Picklist | undefined |
| SubCategoryPicklist__c | Sub-Category | Picklist | undefined |


## Related Flows

| Object | Name | Type | Description | Status |
| :----  | :-------- | :--: | :---------- | :----- |
| 💻 | [AHA_ERL_Example_Flow](../flows/AHA_ERL_Example_Flow.md) [🕒](../flows/AHA_ERL_Example_Flow-history.md) |  Screen Flow | <!-- --> | Draft |




## Related Apex Classes

| Apex Class | Type |
| :----      | :--: | 
| [AhaErlCategoryJunctionHelperTest](../apex/AhaErlCategoryJunctionHelperTest.md) | Test |
| [AhaErlController](../apex/AhaErlController.md) | Lightning Controller |
| [AhaErlGuiCatJunctionHelperTest](../apex/AhaErlGuiCatJunctionHelperTest.md) | Test |
| [AhaErlHierarchyController](../apex/AhaErlHierarchyController.md) | Lightning Controller |
| [AhaErlHierarchyControllerTest](../apex/AhaErlHierarchyControllerTest.md) | Test |
| [AhaErlSeedDataController](../apex/AhaErlSeedDataController.md) | Lightning Controller |
| [AhaErlSeedDataControllerTest](../apex/AhaErlSeedDataControllerTest.md) | Test |


## Related Lightning Pages

| Lightning Page | Type |
| :----      | :--: | 
| [AHA_ERL_CategoryButtonLRP](../pages/AHA_ERL_CategoryButtonLRP.md) |  Record Page |
| [AHA_ERL_Category_Item_List_LRP](../pages/AHA_ERL_Category_Item_List_LRP.md) |  Record Page |
| [AHA_ERL_Category_Record_Page](../pages/AHA_ERL_Category_Record_Page.md) |  Record Page |




## Related Permission Sets

| Permission Set | User License |
| :----      | :--: | 
| [ERL_Full_Access](../permissionsets/ERL_Full_Access.md) | None |




[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
