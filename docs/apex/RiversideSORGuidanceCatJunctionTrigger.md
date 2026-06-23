---
hide:
  - path
---

# RiversideSORGuidanceCatJunctionTrigger Trigger

## Class Diagram

```mermaid
graph TD
  RiversideSORGuidanceCatJunctionTrigger["RiversideSORGuidanceCatJunctionTrigger"]:::mainApexClass
  click RiversideSORGuidanceCatJunctionTrigger "/objects/RiversideSORGuidanceCatJunctionTrigger/"
  RiversideSORGuiCatJunctionTriggerHandler["RiversideSORGuiCatJunctionTriggerHandler"]:::apexClass
  click RiversideSORGuiCatJunctionTriggerHandler "/apex/RiversideSORGuiCatJunctionTriggerHandler/"
  TriggerHandler["TriggerHandler"]:::apexClass
  click TriggerHandler "/apex/TriggerHandler/"

  RiversideSORGuidanceCatJunctionTrigger --> RiversideSORGuiCatJunctionTriggerHandler
  RiversideSORGuidanceCatJunctionTrigger --> TriggerHandler


  RiversideSORGuiCatJunctionTriggerHandler --> TriggerHandler

classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0,1 stroke:#4C9F70,stroke-width:4px;
linkStyle 2 stroke:#A6A6A6,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
trigger RiversideSORGuidanceCatJunctionTrigger on Riverside_SOR_Category_Guidance_Junction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new RiversideSORGuiCatJunctionTriggerHandler().run();
}
```

## Trigger On Riverside_SOR_Category_Guidance_Junction__c

**Run**
* Before Insert
* Before Update
* Before Delete
* After Insert
* After Update
* After Delete
* After Undelete