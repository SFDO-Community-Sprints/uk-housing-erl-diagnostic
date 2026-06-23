---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

## ahaErlProfileAssignment

<!-- LWC description -->

## JS Documentation

## Functions

<dl>
<dt><a href="#fetchSORs">fetchSORs()</a></dt>
<dd><p>Loads all SOR codes with their current assignment status for the given
profile from Apex, then applies client-side filtering.</p>
</dd>
<dt><a href="#handleCopyToClipboard">handleCopyToClipboard()</a></dt>
<dd><p>Copies the current filtered result set to clipboard in tab-delimited format
 so it can be pasted directly into Excel.</p>
</dd>
<dt><a href="#handleDownloadCsv">handleDownloadCsv()</a></dt>
<dd><p>Downloads the current filtered result set as a CSV file for spreadsheet use.</p>
</dd>
<dt><a href="#handleSORCheckboxChange">handleSORCheckboxChange()</a></dt>
<dd><p>Calls Apex to add or remove the SOR assignment for the profile depending
on whether the checkbox was checked or unchecked.</p>
</dd>
<dt><a href="#filterSORs">filterSORs()</a></dt>
<dd><p>Filters the full SOR list by search key, assigned-only, and unassigned-only
 flags, then recalculates page count and assignment/unassignment totals.</p>
</dd>
</dl>

<a name="fetchSORs"></a>

## fetchSORs()
Loads all SOR codes with their current assignment status for the given
profile from Apex, then applies client-side filtering.

**Kind**: global function  
<a name="handleCopyToClipboard"></a>

## handleCopyToClipboard()
Copies the current filtered result set to clipboard in tab-delimited format
 so it can be pasted directly into Excel.

**Kind**: global function  
<a name="handleDownloadCsv"></a>

## handleDownloadCsv()
Downloads the current filtered result set as a CSV file for spreadsheet use.

**Kind**: global function  
<a name="handleSORCheckboxChange"></a>

## handleSORCheckboxChange()
Calls Apex to add or remove the SOR assignment for the profile depending
on whether the checkbox was checked or unchecked.

**Kind**: global function  
<a name="filterSORs"></a>

## filterSORs()
Filters the full SOR list by search key, assigned-only, and unassigned-only
 flags, then recalculates page count and assignment/unassignment totals.

**Kind**: global function  


## Files

- `ahaErlProfileAssignment.html`
- `ahaErlProfileAssignment.js`
- `ahaErlProfileAssignment.js-meta.xml`



[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
