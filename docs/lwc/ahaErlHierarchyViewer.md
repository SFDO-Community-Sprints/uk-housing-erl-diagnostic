---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

## ahaErlHierarchyViewer

<!-- LWC description -->

## JS Documentation

## Functions

<dl>
<dt><a href="#wiredProfiles">wiredProfiles()</a></dt>
<dd><p>Wire handler that fetches the list of repair profile options from Apex;
auto-selects the first profile and triggers a hierarchy data load when results arrive.</p>
</dd>
<dt><a href="#handleCopyToClipboard">handleCopyToClipboard()</a></dt>
<dd><p>Builds a tab-delimited string of the current filtered data and writes it
 to the clipboard, formatted for direct paste into Excel.</p>
</dd>
<dt><a href="#handleDownloadCsv">handleDownloadCsv()</a></dt>
<dd><p>Downloads the current filtered dataset as a CSV file so it can be opened
 directly in Excel or any spreadsheet tool.</p>
</dd>
<dt><a href="#loadHierarchyData">loadHierarchyData()</a></dt>
<dd><p>Fetches the full SOR hierarchy data for the selected profile from Apex,
including an optional closeup filter, then applies client-side filtering.</p>
</dd>
<dt><a href="#filterData">filterData()</a></dt>
<dd><p>Applies the active search term and accessibility filter to hierarchyData,
 then re-applies any active column sort.</p>
</dd>
<dt><a href="#sortData">sortData()</a></dt>
<dd><p>Sorts filteredData by the given field and direction; coerces booleans to
 integers so they sort correctly alongside text fields.</p>
</dd>
</dl>

<a name="wiredProfiles"></a>

## wiredProfiles()
Wire handler that fetches the list of repair profile options from Apex;
auto-selects the first profile and triggers a hierarchy data load when results arrive.

**Kind**: global function  
<a name="handleCopyToClipboard"></a>

## handleCopyToClipboard()
Builds a tab-delimited string of the current filtered data and writes it
 to the clipboard, formatted for direct paste into Excel.

**Kind**: global function  
<a name="handleDownloadCsv"></a>

## handleDownloadCsv()
Downloads the current filtered dataset as a CSV file so it can be opened
 directly in Excel or any spreadsheet tool.

**Kind**: global function  
<a name="loadHierarchyData"></a>

## loadHierarchyData()
Fetches the full SOR hierarchy data for the selected profile from Apex,
including an optional closeup filter, then applies client-side filtering.

**Kind**: global function  
<a name="filterData"></a>

## filterData()
Applies the active search term and accessibility filter to hierarchyData,
 then re-applies any active column sort.

**Kind**: global function  
<a name="sortData"></a>

## sortData()
Sorts filteredData by the given field and direction; coerces booleans to
 integers so they sort correctly alongside text fields.

**Kind**: global function  


## Files

- `ahaErlHierarchyViewer.html`
- `ahaErlHierarchyViewer.js`
- `ahaErlHierarchyViewer.js-meta.xml`



[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
