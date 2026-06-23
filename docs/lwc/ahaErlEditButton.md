---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

## ahaErlEditButton

<!-- LWC description -->

## JS Documentation

## Functions

<dl>
<dt><a href="#renderedCallback">renderedCallback()</a></dt>
<dd><p>Fetches the current profile assignments for the SOR being edited from Apex
the first time the edit popover is rendered in search-edit mode.</p>
</dd>
<dt><a href="#handleEditSave">handleEditSave()</a></dt>
<dd><p>Routes the save action to editSORProfiles, editMessage, or editCategory
 based on the component&#39;s current edit context flags.</p>
</dd>
<dt><a href="#editSORProfiles">editSORProfiles()</a></dt>
<dd><p>Saves the updated profile assignments for a SOR code to Salesforce via Apex.</p>
</dd>
<dt><a href="#editGuidance">editGuidance()</a></dt>
<dd><p>Saves rich-text guidance for the current closeup category and active profile.</p>
</dd>
<dt><a href="#editMessage">editMessage()</a></dt>
<dd><p>Saves edits to a message-type SOR record and its profile assignments via Apex.</p>
</dd>
<dt><a href="#editCategory">editCategory()</a></dt>
<dd><p>Saves edits to the label, image, guided flag, and profile assignments of the
current category record via Apex.</p>
</dd>
<dt><a href="#addNewMessage">addNewMessage()</a></dt>
<dd><p>Creates a new message junction or links an existing message to the category
via Apex, depending on whether the user selected an existing message.</p>
</dd>
<dt><a href="#addNewSOR">addNewSOR()</a></dt>
<dd><p>Links the chosen SOR code to the current category via Apex.</p>
</dd>
<dt><a href="#addNewCategory">addNewCategory()</a></dt>
<dd><p>Creates a new child category under the current parent with the provided
label, image, record type, and profile assignments via Apex.</p>
</dd>
<dt><a href="#deleteMessageFromCategory">deleteMessageFromCategory()</a></dt>
<dd><p>Removes the message junction record from the category via Apex.</p>
</dd>
<dt><a href="#deleteCategory">deleteCategory()</a></dt>
<dd><p>Deletes the current category record and its child relationships via Apex.</p>
</dd>
<dt><a href="#handleEdit">handleEdit()</a></dt>
<dd><p>Opens the edit popover; fetches all available messages from Apex when editing
a message node, and fetches current profile junctions from Apex when editing an existing category or SOR.</p>
</dd>
</dl>

<a name="renderedCallback"></a>

## renderedCallback()
Fetches the current profile assignments for the SOR being edited from Apex
the first time the edit popover is rendered in search-edit mode.

**Kind**: global function  
<a name="handleEditSave"></a>

## handleEditSave()
Routes the save action to editSORProfiles, editMessage, or editCategory
 based on the component's current edit context flags.

**Kind**: global function  
<a name="editSORProfiles"></a>

## editSORProfiles()
Saves the updated profile assignments for a SOR code to Salesforce via Apex.

**Kind**: global function  
<a name="editGuidance"></a>

## editGuidance()
Saves rich-text guidance for the current closeup category and active profile.

**Kind**: global function  
<a name="editMessage"></a>

## editMessage()
Saves edits to a message-type SOR record and its profile assignments via Apex.

**Kind**: global function  
<a name="editCategory"></a>

## editCategory()
Saves edits to the label, image, guided flag, and profile assignments of the
current category record via Apex.

**Kind**: global function  
<a name="addNewMessage"></a>

## addNewMessage()
Creates a new message junction or links an existing message to the category
via Apex, depending on whether the user selected an existing message.

**Kind**: global function  
<a name="addNewSOR"></a>

## addNewSOR()
Links the chosen SOR code to the current category via Apex.

**Kind**: global function  
<a name="addNewCategory"></a>

## addNewCategory()
Creates a new child category under the current parent with the provided
label, image, record type, and profile assignments via Apex.

**Kind**: global function  
<a name="deleteMessageFromCategory"></a>

## deleteMessageFromCategory()
Removes the message junction record from the category via Apex.

**Kind**: global function  
<a name="deleteCategory"></a>

## deleteCategory()
Deletes the current category record and its child relationships via Apex.

**Kind**: global function  
<a name="handleEdit"></a>

## handleEdit()
Opens the edit popover; fetches all available messages from Apex when editing
a message node, and fetches current profile junctions from Apex when editing an existing category or SOR.

**Kind**: global function  


## Files

- `ahaErlEditButton.css`
- `ahaErlEditButton.html`
- `ahaErlEditButton.js`
- `ahaErlEditButton.js-meta.xml`



[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
