---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->


## Schema

```mermaid
graph TD
AHA_ERL_Guidance__c["AHA-ERL Guidance"]:::customObject
click AHA_ERL_Guidance__c "/objects/AHA_ERL_Guidance__c/"
AHA_ERL_Code_Profile__c["AHA-ERL Code Profile"]:::customObject
click AHA_ERL_Code_Profile__c "/objects/AHA_ERL_Code_Profile__c/"
AHA_ERL_Category__c["AHA-ERL Category"]:::customObject
click AHA_ERL_Category__c "/objects/AHA_ERL_Category__c/"
AHA_ERL_Category_Guidance_Junction__c["AHA-ERL Category-Guidance Junction"]:::mainObject
click AHA_ERL_Category_Guidance_Junction__c "/objects/AHA_ERL_Category_Guidance_Junction__c/"

AHA_ERL_Category__c -->|RedirectToLookup__c| AHA_ERL_Category__c
AHA_ERL_Category__c -->|ParentCategoryLookup__c| AHA_ERL_Category__c
AHA_ERL_Category_Guidance_Junction__c -->|Profile__c| AHA_ERL_Code_Profile__c
AHA_ERL_Category_Guidance_Junction__c ==>|Guidance__c| AHA_ERL_Guidance__c
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
| Category__c | Category | MasterDetail | undefined |
| ExternalIdentifier__c | External Identifier | Text | undefined |
| Guidance__c | Guidance | MasterDetail | undefined |
| Profile__c | Profile | Lookup | undefined |






## Related Apex Classes

| Apex Class | Type |
| :----      | :--: | 
| [AhaErlController](../apex/AhaErlController.md) | Lightning Controller |
| [AhaErlGuiCatJunctionHelper](../apex/AhaErlGuiCatJunctionHelper.md) | Class |
| [AhaErlGuiCatJunctionHelperTest](../apex/AhaErlGuiCatJunctionHelperTest.md) | Test |
| [AhaErlGuidanceCatJunctionTrigger](../apex/AhaErlGuidanceCatJunctionTrigger.md) | Trigger |






## Related Permission Sets

| Permission Set | User License |
| :----      | :--: | 
| [ERL_Full_Access](../permissionsets/ERL_Full_Access.md) | None |




[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
