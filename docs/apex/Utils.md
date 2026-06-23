---
hide:
  - path
---

# Utils Class

## Class Diagram

```mermaid
graph TD
  Utils["Utils"]:::mainApexClass
  click Utils "/objects/Utils/"
  RiversideSORController["RiversideSORController"]:::apexClass
  click RiversideSORController "/apex/RiversideSORController/"


  RiversideSORController --> Utils


classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#FF8C00,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
public with sharing class Utils {

    @AuraEnabled
    public static Boolean isSandbox() {
        //customer user compatible
        return system.URL.getOrgDomainUrl().toString().contains('.sandbox.');
    }

    public static Boolean validateAdminUser() {
        Boolean isAdmin = false;
        User currentUser = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id =: UserInfo.getUserId()
        ];
        if (currentUser.Profile.Name == 'System Administrator') {
            isAdmin = true;
        }
        return isAdmin;
    }

}

```

## Methods
### `isSandbox()`

`AURAENABLED`

#### Signature
```apex
public static Boolean isSandbox()
```

#### Return Type
**Boolean**

---

### `validateAdminUser()`

#### Signature
```apex
public static Boolean validateAdminUser()
```

#### Return Type
**Boolean**