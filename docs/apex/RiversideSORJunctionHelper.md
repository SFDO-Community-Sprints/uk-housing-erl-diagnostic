---
hide:
  - path
---

# RiversideSORJunctionHelper Class

## Class Diagram

```mermaid
graph TD
  RiversideSORJunctionHelper["RiversideSORJunctionHelper"]:::mainApexClass
  click RiversideSORJunctionHelper "/objects/RiversideSORJunctionHelper/"
  RiversideSORJunctionTriggerHandler["RiversideSORJunctionTriggerHandler"]:::apexClass
  click RiversideSORJunctionTriggerHandler "/apex/RiversideSORJunctionTriggerHandler/"


  RiversideSORJunctionTriggerHandler --> RiversideSORJunctionHelper


classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#FF8C00,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
public with sharing class RiversideSORJunctionHelper {
    public static void updateExternalIdentifier(Set<Id> junctionids) {
        List<Riverside_SOR_Junction__c> junctionsToUpdate = [SELECT Id, ExternalIdentifier__c FROM Riverside_SOR_Junction__c WHERE Id IN :junctionids AND ExternalIdentifier__c = null];
        if (!junctionsToUpdate.isEmpty()) {
            for (Riverside_SOR_Junction__c junction : junctionsToUpdate) {
                junction.ExternalIdentifier__c = 'RSJ' + junction.Id;
            }
            update junctionsToUpdate;
        }
    }
}
```

## Methods
### `updateExternalIdentifier(junctionids)`

#### Signature
```apex
public static void updateExternalIdentifier(Set<Id> junctionids)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| junctionids | Set<Id> |  |

#### Return Type
**void**