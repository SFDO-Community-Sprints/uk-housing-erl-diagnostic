---
hide:
  - path
---

## Class Diagram

```mermaid
graph TD
  TriggerHandlerException["TriggerHandlerException"]:::mainApexClass
  click TriggerHandlerException "/objects/TriggerHandlerException/"
  TriggerHandler["TriggerHandler"]:::apexClass
  click TriggerHandler "/apex/TriggerHandler/"
  TriggerHandlerTest["TriggerHandlerTest"]:::apexTestClass
  click TriggerHandlerTest "/apex/TriggerHandlerTest/"

  TriggerHandlerException --> TriggerHandler

  TriggerHandler --> TriggerHandlerException
  TriggerHandlerTest --> TriggerHandlerException

  TriggerHandlerTest --> TriggerHandler

classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
linkStyle 1,2 stroke:#FF8C00,stroke-width:2px;
linkStyle 3 stroke:#A6A6A6,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
public class TriggerHandlerException extends Exception {}
```

# TriggerHandlerException Class

**Inheritance**

Exception