---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->


## Schema

```mermaid
graph TD
Riverside_SOR_Junction__c["Riverside SOR-Profile Junction"]:::mainObject
click Riverside_SOR_Junction__c "/objects/Riverside_SOR_Junction__c/"
Riverside_SOR_Code__c["Riverside SOR Code"]:::customObject
click Riverside_SOR_Code__c "/objects/Riverside_SOR_Code__c/"
Riverside_SOR_Code_Profile__c["Riverside SOR Code Profile"]:::customObject
click Riverside_SOR_Code_Profile__c "/objects/Riverside_SOR_Code_Profile__c/"
Riverside_SOR_Category__c["Riverside SOR Category"]:::customObject
click Riverside_SOR_Category__c "/objects/Riverside_SOR_Category__c/"

Riverside_SOR_Junction__c ==>|SORProfile__c| Riverside_SOR_Code_Profile__c
Riverside_SOR_Junction__c -->|SORCode__c| Riverside_SOR_Code__c
Riverside_SOR_Junction__c -->|SORCategory__c| Riverside_SOR_Category__c
Riverside_SOR_Category__c -->|RedirectToLookup__c| Riverside_SOR_Category__c
Riverside_SOR_Category__c -->|ParentCategoryLookup__c| Riverside_SOR_Category__c

classDef object fill:#D6E9FF,stroke:#0070D2,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObject fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef customObjectManaged fill:#FFD8B2,stroke:#CC5500,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainObject fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;
linkStyle 0 stroke:#4C9F70,stroke-width:4px;
linkStyle 1,2,3,4 stroke:#A6A6A6,stroke-width:2px;

```


<!-- Object description -->

## Fields

| Name | Label | Type | Description |
| :-------- | :---- | :--: | :---------- | 
| ExternalIdentifier__c | ExternalIdentifier | Text | undefined |
| SORCategory__c | SOR Category | Lookup | undefined |
| SORCode__c | SOR Code | Lookup | undefined |
| SORProfile__c | SOR Profile | MasterDetail | undefined |






## Related Apex Classes

| Apex Class | Type |
| :----      | :--: | 
| [RiversideSORController](../apex/RiversideSORController.md) | Lightning Controller |
| [RiversideSORHierarchyController](../apex/RiversideSORHierarchyController.md) | Lightning Controller |
| [RiversideSORHierarchyControllerTest](../apex/RiversideSORHierarchyControllerTest.md) | Test |
| [RiversideSORJunctionHelper](../apex/RiversideSORJunctionHelper.md) | Class |
| [RiversideSORJunctionTrigger](../apex/RiversideSORJunctionTrigger.md) | Trigger |






## Related Permission Sets

| Permission Set | User License |
| :----      | :--: | 
| [ERL_Full_Access](../permissionsets/ERL_Full_Access.md) | None |




[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
