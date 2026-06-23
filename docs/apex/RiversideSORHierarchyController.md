---
hide:
  - path
---

# RiversideSORHierarchyController Class

## Class Diagram

```mermaid
graph TD
  RiversideSORHierarchyController["RiversideSORHierarchyController"]:::mainApexClass
  click RiversideSORHierarchyController "/objects/RiversideSORHierarchyController/"
  RiversideSORHierarchyControllerTest["RiversideSORHierarchyControllerTest"]:::apexTestClass
  click RiversideSORHierarchyControllerTest "/apex/RiversideSORHierarchyControllerTest/"


  RiversideSORHierarchyControllerTest --> RiversideSORHierarchyController


classDef apexClass fill:#FFF4C2,stroke:#CCAA00,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef apexTestClass fill:#F5F5F5,stroke:#999999,stroke-width:3px,rx:12px,ry:12px,shadow:drop,color:#333;
classDef mainApexClass fill:#FFB3B3,stroke:#A94442,stroke-width:4px,rx:14px,ry:14px,shadow:drop,color:#333,font-weight:bold;

linkStyle 0 stroke:#FF8C00,stroke-width:2px;
```

<!-- Apex description -->

## Apex Code

```java
public with sharing class RiversideSORHierarchyController {
    
    public class SORHierarchyData {
        @AuraEnabled
        public String sorId;
        @AuraEnabled
        public String sorCode;
        @AuraEnabled
        public String sorHeadingText;
        @AuraEnabled
        public String categoryPath;
        @AuraEnabled
        public String categoryId;
        @AuraEnabled
        public Boolean isAccessible;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SORHierarchyData> getSORHierarchyData(String profileName, Boolean includeCloseups) {
        // Get the profile ID
        Id profileId = getProfileId(profileName);
        if (profileId == null) {
            return new List<SORHierarchyData>();
        }
        
        // Get all accessible categories for this profile
        Set<Id> accessibleCategoryIds = getAccessibleCategories(profileId);
        
        // Build category hierarchy map
        Map<Id, Riverside_SOR_Category__c> allCategories = new Map<Id, Riverside_SOR_Category__c>(
            [SELECT Id, Label__c, ParentCategoryLookup__c, RecordType.DeveloperName
             FROM Riverside_SOR_Category__c]
        );
        
        // Get all SOR to Category junctions
        List<Riverside_SOR_Category_Junction__c> sorCategoryJunctions = [
            SELECT Riverside_SOR_Code__c, 
                   Riverside_SOR_Category__c,
                   Riverside_SOR_Code__r.SORCodeText__c,
                   Riverside_SOR_Code__r.SORHeadingText__c
            FROM Riverside_SOR_Category_Junction__c
            WHERE Riverside_SOR_Code__r.RecordType.DeveloperName != 'Message'
            ORDER BY Riverside_SOR_Code__r.SORCodeText__c, Riverside_SOR_Category__c
        ];
        
        // Get all SORs that are assigned to this profile
        Set<Id> profileSORIds = new Set<Id>();
        for (Riverside_SOR_Junction__c junction : [
            SELECT SORCode__c 
            FROM Riverside_SOR_Junction__c 
            WHERE SORProfile__c = :profileId 
              AND SORCode__c != null
        ]) {
            profileSORIds.add(junction.SORCode__c);
        }
        
        List<SORHierarchyData> results = new List<SORHierarchyData>();
        
        // Process each SOR-Category junction as a separate row
        for (Riverside_SOR_Category_Junction__c junction : sorCategoryJunctions) {
            // Skip if SOR not assigned to profile
            if (!profileSORIds.contains(junction.Riverside_SOR_Code__c)) {
                continue;
            }
            
            SORHierarchyData data = new SORHierarchyData();
            data.sorId = junction.Riverside_SOR_Code__c;
            data.sorCode = junction.Riverside_SOR_Code__r.SORCodeText__c;
            data.sorHeadingText = junction.Riverside_SOR_Code__r.SORHeadingText__c;
            data.categoryId = junction.Riverside_SOR_Category__c;
            
            // Build category path
            data.categoryPath = buildCategoryPath(junction.Riverside_SOR_Category__c, allCategories, includeCloseups);
            
            // Check if the entire path is accessible
            data.isAccessible = isCategoryPathAccessible(
                junction.Riverside_SOR_Category__c, 
                allCategories, 
                accessibleCategoryIds
            );
            
            results.add(data);
        }
        
        return results;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProfileOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        for (Riverside_SOR_Code_Profile__c profile : [
            SELECT Id, Name, Description__c 
            FROM Riverside_SOR_Code_Profile__c 
            ORDER BY Name ASC
        ]) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', profile.Name);
            option.put('value', profile.Name);
            options.add(option);
        }
        
        return options;
    }
    
    private static Id getProfileId(String profileName) {
        List<Riverside_SOR_Code_Profile__c> profiles = [
            SELECT Id 
            FROM Riverside_SOR_Code_Profile__c 
            WHERE Name = :profileName 
            LIMIT 1
        ];
        
        return profiles.isEmpty() ? null : profiles[0].Id;
    }
    
    private static Set<Id> getAccessibleCategories(Id profileId) {
        Set<Id> accessibleIds = new Set<Id>();
        
        for (Riverside_SOR_Junction__c junction : [
            SELECT SORCategory__c 
            FROM Riverside_SOR_Junction__c 
            WHERE SORProfile__c = :profileId 
              AND SORCategory__c != null
        ]) {
            accessibleIds.add(junction.SORCategory__c);
        }
        
        return accessibleIds;
    }
    
    private static String buildCategoryPath(Id categoryId, Map<Id, Riverside_SOR_Category__c> allCategories, Boolean includeCloseups) {
        if (categoryId == null || allCategories == null || allCategories.isEmpty()) {
            return 'Unknown';
        }
        
        List<String> pathParts = new List<String>();
        Id currentId = categoryId;
        Set<Id> visited = new Set<Id>(); // Prevent infinite loops
        Integer maxDepth = 20; // Safety limit
        Integer depth = 0;
        
        while (currentId != null && !visited.contains(currentId) && depth < maxDepth) {
            visited.add(currentId);
            depth++;
            
            if (!allCategories.containsKey(currentId)) {
                break;
            }
            
            Riverside_SOR_Category__c category = allCategories.get(currentId);
            
            if (category == null) {
                break;
            }
            
            // Skip closeups if includeCloseups is false
            Boolean isCloseup = category.RecordType.DeveloperName == 'RepairLocationCloseup';
            
            if (String.isNotBlank(category.Label__c) && (includeCloseups || !isCloseup)) {
                pathParts.add(category.Label__c); // Add to end, we'll reverse later
            }
            currentId = category.ParentCategoryLookup__c;
        }
        
        if (pathParts.isEmpty()) {
            return 'Unknown';
        }
        
        // Reverse the list to get root-to-leaf order
        List<String> reversedPath = new List<String>();
        for (Integer i = pathParts.size() - 1; i >= 0; i--) {
            reversedPath.add(pathParts.get(i));
        }
        
        String result = '';
        for (Integer i = 0; i < reversedPath.size(); i++) {
            if (i > 0) {
                result += ' > ';
            }
            result += reversedPath.get(i);
        }
        
        return result;
    }
    
    private static Boolean isCategoryPathAccessible(
        Id categoryId, 
        Map<Id, Riverside_SOR_Category__c> allCategories,
        Set<Id> accessibleCategoryIds
    ) {
        Id currentId = categoryId;
        Set<Id> visited = new Set<Id>(); // Prevent infinite loops
        
        // Check each level from current category up to root
        while (currentId != null && !visited.contains(currentId)) {
            visited.add(currentId);
            
            // If any category in the path is not accessible, return false
            if (!accessibleCategoryIds.contains(currentId)) {
                return false;
            }
            
            Riverside_SOR_Category__c category = allCategories.get(currentId);
            if (category == null) {
                break;
            }
            
            currentId = category.ParentCategoryLookup__c;
        }
        
        return true;
    }
}

```

## Methods
### `getSORHierarchyData(profileName, includeCloseups)`

`AURAENABLED`

#### Signature
```apex
public static List<SORHierarchyData> getSORHierarchyData(String profileName, Boolean includeCloseups)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| profileName | String |  |
| includeCloseups | Boolean |  |

#### Return Type
**List<SORHierarchyData>**

---

### `getProfileOptions()`

`AURAENABLED`

#### Signature
```apex
public static List<Map<String,String>> getProfileOptions()
```

#### Return Type
**List<Map<String,String>>**

---

### `getProfileId(profileName)`

#### Signature
```apex
private static Id getProfileId(String profileName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| profileName | String |  |

#### Return Type
**Id**

---

### `getAccessibleCategories(profileId)`

#### Signature
```apex
private static Set<Id> getAccessibleCategories(Id profileId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| profileId | Id |  |

#### Return Type
**Set<Id>**

---

### `buildCategoryPath(categoryId, allCategories, includeCloseups)`

#### Signature
```apex
private static String buildCategoryPath(Id categoryId, Map<Id,Riverside_SOR_Category__c> allCategories, Boolean includeCloseups)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| categoryId | Id |  |
| allCategories | Map<Id,Riverside_SOR_Category__c> |  |
| includeCloseups | Boolean |  |

#### Return Type
**String**

---

### `isCategoryPathAccessible(categoryId, allCategories, accessibleCategoryIds)`

#### Signature
```apex
private static Boolean isCategoryPathAccessible(Id categoryId, Map<Id,Riverside_SOR_Category__c> allCategories, Set<Id> accessibleCategoryIds)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| categoryId | Id |  |
| allCategories | Map<Id,Riverside_SOR_Category__c> |  |
| accessibleCategoryIds | Set<Id> |  |

#### Return Type
**Boolean**

## Classes
### SORHierarchyData Class

#### Fields
##### `sorId`

`AURAENABLED`

###### Signature
```apex
public sorId
```

###### Type
String

---

##### `sorCode`

`AURAENABLED`

###### Signature
```apex
public sorCode
```

###### Type
String

---

##### `sorHeadingText`

`AURAENABLED`

###### Signature
```apex
public sorHeadingText
```

###### Type
String

---

##### `categoryPath`

`AURAENABLED`

###### Signature
```apex
public categoryPath
```

###### Type
String

---

##### `categoryId`

`AURAENABLED`

###### Signature
```apex
public categoryId
```

###### Type
String

---

##### `isAccessible`

`AURAENABLED`

###### Signature
```apex
public isAccessible
```

###### Type
Boolean