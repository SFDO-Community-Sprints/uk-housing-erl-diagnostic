---
hide:
  - path
---

# RiversideSORJunctionTrigger Trigger

## Class Diagram

```mermaid
graph TD
  RiversideSORJunctionTrigger["RiversideSORJunctionTrigger"]:::mainApexClass
  click RiversideSORJunctionTrigger "/objects/RiversideSORJunctionTrigger/"
  RiversideSORJunctionTriggerHandler["RiversideSORJunctionTriggerHandler"]:::apexClass
  click RiversideSORJunctionTriggerHandler "/apex/RiversideSORJunctionTriggerHandler/"
  TriggerHandler["TriggerHandler"]:::apexClass
  click TriggerHandler "/apex/TriggerHandler/"

  RiversideSORJunctionTrigger --> RiversideSORJunctionTriggerHandler
  RiversideSORJunctionTrigger --> TriggerHandler

  RiversideSORJunctionTriggerHandler --> RiversideSORJunctionTrigger

  RiversideSORJunctionTriggerHandler --> TriggerHandler

classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0,1 stroke:#4C9F70,stroke-width:4px;
linkStyle 2 stroke:#FF8C00,stroke-width:2px;
linkStyle 3 stroke:#A6A6A6,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
trigger RiversideSORJunctionTrigger on Riverside_SOR_Junction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new RiversideSORJunctionTriggerHandler().run();
}
```

## Trigger On Riverside_SOR_Junction__c

**Run**
* Before Insert
* Before Update
* Before Delete
* After Insert
* After Update
* After Delete
* After Undelete