---
hide:
  - path
---

# AhaErlJunctionTrigger Trigger

## Class Diagram

```mermaid
graph TD
  AhaErlJunctionTrigger["AhaErlJunctionTrigger"]:::mainApexClass
  click AhaErlJunctionTrigger "/objects/AhaErlJunctionTrigger/"
  AhaErlJunctionHelper["AhaErlJunctionHelper"]:::apexClass
  click AhaErlJunctionHelper "/apex/AhaErlJunctionHelper/"

  AhaErlJunctionTrigger --> AhaErlJunctionHelper



classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
```

<!-- Apex description -->

## Apex Code

```java
trigger AhaErlJunctionTrigger on AHA_ERL_Junction__c (after insert) {
    AhaErlJunctionHelper.updateExternalIdentifier(Trigger.newMap.keySet());
}
```

## Trigger On AHA_ERL_Junction__c

**Run**
* After Insert