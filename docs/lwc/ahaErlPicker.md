---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

## ahaErlPicker

<!-- LWC description -->

## JS Documentation

## Functions

<dl>
<dt><a href="#connectedCallback">connectedCallback()</a></dt>
<dd><p>Initialises the component by fetching root categories for the current profile,
available repair locations, all repair profiles (edit mode only), and the sandbox flag from Apex.
In edit context, also checks whether ERL is empty to conditionally show the seed data button.</p>
</dd>
<dt><a href="#handleGenerateSeedData">handleGenerateSeedData()</a></dt>
<dd><p>Calls Apex to generate the example data hierarchy, then reloads categories.</p>
</dd>
<dt><a href="#handleEditedCategory">handleEditedCategory()</a></dt>
<dd><p>Refreshes the root category list from Apex after a profile change or
an admin edit to a category.</p>
</dd>
<dt><a href="#markActiveDisplayedCategories">markActiveDisplayedCategories()</a></dt>
<dd><p>Marks the currently selected category as active in the displayed list
 to drive active-state styling in the template.</p>
</dd>
<dt><a href="#handleSorSelection">handleSorSelection()</a></dt>
<dd><p>Adds the selected SOR to the list, rejecting duplicates with a toast.</p>
</dd>
<dt><a href="#handleGuidedSubmit">handleGuidedSubmit()</a></dt>
<dd><p>Collects SORs from a guided-mode problem selection, attaches the user&#39;s
 free-text details to each, and advances the flow.</p>
</dd>
<dt><a href="#logTrackingData">logTrackingData()</a></dt>
<dd><p>Builds and fires a tracking record to Apex with elapsed time, navigation
 path, and type (PARTIAL vs COMPLETE), then resets the path/timer for the next segment.</p>
</dd>
<dt><a href="#outputText">outputText()</a></dt>
<dd><p>Serialises the selected SOR list to the JSON output format expected by
 downstream Flow variables and external integrations.</p>
</dd>
<dt><a href="#unOutputText">unOutputText()</a></dt>
<dd><p>Deserialises a previously serialised JSON output back into the selectedSORs
 array, resolving location labels from the loaded locations map.</p>
</dd>
</dl>

<a name="connectedCallback"></a>

## connectedCallback()
Initialises the component by fetching root categories for the current profile,
available repair locations, all repair profiles (edit mode only), and the sandbox flag from Apex.
In edit context, also checks whether ERL is empty to conditionally show the seed data button.

**Kind**: global function  
<a name="handleGenerateSeedData"></a>

## handleGenerateSeedData()
Calls Apex to generate the example data hierarchy, then reloads categories.

**Kind**: global function  
<a name="handleEditedCategory"></a>

## handleEditedCategory()
Refreshes the root category list from Apex after a profile change or
an admin edit to a category.

**Kind**: global function  
<a name="markActiveDisplayedCategories"></a>

## markActiveDisplayedCategories()
Marks the currently selected category as active in the displayed list
 to drive active-state styling in the template.

**Kind**: global function  
<a name="handleSorSelection"></a>

## handleSorSelection()
Adds the selected SOR to the list, rejecting duplicates with a toast.

**Kind**: global function  
<a name="handleGuidedSubmit"></a>

## handleGuidedSubmit()
Collects SORs from a guided-mode problem selection, attaches the user's
 free-text details to each, and advances the flow.

**Kind**: global function  
<a name="logTrackingData"></a>

## logTrackingData()
Builds and fires a tracking record to Apex with elapsed time, navigation
 path, and type (PARTIAL vs COMPLETE), then resets the path/timer for the next segment.

**Kind**: global function  
<a name="outputText"></a>

## outputText()
Serialises the selected SOR list to the JSON output format expected by
 downstream Flow variables and external integrations.

**Kind**: global function  
<a name="unOutputText"></a>

## unOutputText()
Deserialises a previously serialised JSON output back into the selectedSORs
 array, resolving location labels from the loaded locations map.

**Kind**: global function  


## Files

- `ahaErlPicker.css`
- `ahaErlPicker.html`
- `ahaErlPicker.js`
- `ahaErlPicker.js-meta.xml`



[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
