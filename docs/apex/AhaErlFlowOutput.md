---
hide:
  - path
---

# AhaErlFlowOutput Class

## Class Diagram

```mermaid
graph TD
  AhaErlFlowOutput["AhaErlFlowOutput"]:::mainApexClass
  click AhaErlFlowOutput "/objects/AhaErlFlowOutput/"
  AhaErlFlowOutputLine["AhaErlFlowOutputLine"]:::apexClass
  click AhaErlFlowOutputLine "/apex/AhaErlFlowOutputLine/"

  AhaErlFlowOutput --> AhaErlFlowOutputLine

  AhaErlFlowOutputLine --> AhaErlFlowOutput


classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
linkStyle 1 stroke:#FF8C00,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
global class AhaErlFlowOutput {
    @AuraEnabled public String userId { get; set; }
    @AuraEnabled public String userName { get; set; }
    @AuraEnabled public String timestamp { get; set; }
    @AuraEnabled public List<AhaErlFlowOutputLine> repairSorLines { get; set; }
}

```

## Properties
### `userId`

`AURAENABLED`

#### Signature
```apex
public userId
```

#### Type
String

---

### `userName`

`AURAENABLED`

#### Signature
```apex
public userName
```

#### Type
String

---

### `timestamp`

`AURAENABLED`

#### Signature
```apex
public timestamp
```

#### Type
String

---

### `repairSorLines`

`AURAENABLED`

#### Signature
```apex
public repairSorLines
```

#### Type
List<AhaErlFlowOutputLine>