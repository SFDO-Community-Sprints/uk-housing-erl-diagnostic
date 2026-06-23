---
hide:
  - path
---

# AhaErlFlowOutputLine Class

## Class Diagram

```mermaid
graph TD
  AhaErlFlowOutputLine["AhaErlFlowOutputLine"]:::mainApexClass
  click AhaErlFlowOutputLine "/objects/AhaErlFlowOutputLine/"
  AhaErlFlowOutput["AhaErlFlowOutput"]:::apexClass
  click AhaErlFlowOutput "/apex/AhaErlFlowOutput/"

  AhaErlFlowOutputLine --> AhaErlFlowOutput

  AhaErlFlowOutput --> AhaErlFlowOutputLine


classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#4C9F70,stroke-width:4px;
linkStyle 1 stroke:#FF8C00,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
global class AhaErlFlowOutputLine {
    @AuraEnabled public String outputReference { get; set; }
    @AuraEnabled public String sorUnit { get; set; }
    @AuraEnabled public String sorTrade { get; set; }
    @AuraEnabled public String sorCode { get; set; }
    @AuraEnabled public String sorSubject { get; set; }
    @AuraEnabled public String sorDescription { get; set; }
    @AuraEnabled public String sorQuantity { get; set; }
    @AuraEnabled public String sorPriority { get; set; }
    @AuraEnabled public String sorJobTitle { get; set; }
    @AuraEnabled public String sorHeading { get; set; }
    @AuraEnabled public String sorComment { get; set; }
    @AuraEnabled public String sorRate { get; set; }
    @AuraEnabled public String repairLocation { get; set; }
}

```

## Properties
### `outputReference`

`AURAENABLED`

#### Signature
```apex
public outputReference
```

#### Type
String

---

### `sorUnit`

`AURAENABLED`

#### Signature
```apex
public sorUnit
```

#### Type
String

---

### `sorTrade`

`AURAENABLED`

#### Signature
```apex
public sorTrade
```

#### Type
String

---

### `sorCode`

`AURAENABLED`

#### Signature
```apex
public sorCode
```

#### Type
String

---

### `sorSubject`

`AURAENABLED`

#### Signature
```apex
public sorSubject
```

#### Type
String

---

### `sorDescription`

`AURAENABLED`

#### Signature
```apex
public sorDescription
```

#### Type
String

---

### `sorQuantity`

`AURAENABLED`

#### Signature
```apex
public sorQuantity
```

#### Type
String

---

### `sorPriority`

`AURAENABLED`

#### Signature
```apex
public sorPriority
```

#### Type
String

---

### `sorJobTitle`

`AURAENABLED`

#### Signature
```apex
public sorJobTitle
```

#### Type
String

---

### `sorHeading`

`AURAENABLED`

#### Signature
```apex
public sorHeading
```

#### Type
String

---

### `sorComment`

`AURAENABLED`

#### Signature
```apex
public sorComment
```

#### Type
String

---

### `sorRate`

`AURAENABLED`

#### Signature
```apex
public sorRate
```

#### Type
String

---

### `repairLocation`

`AURAENABLED`

#### Signature
```apex
public repairLocation
```

#### Type
String