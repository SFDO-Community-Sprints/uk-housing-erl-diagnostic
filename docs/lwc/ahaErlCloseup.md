---
hide:
  - path
---

<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

## ahaErlCloseup

<!-- LWC description -->

## JS Documentation

## Functions

<dl>
<dt><a href="#syncCopiedButtons">syncCopiedButtons()</a></dt>
<dd><p>Deep-clones the buttons array so child components receive a new reference
 and re-render when disabled state changes.</p>
</dd>
<dt><a href="#getCoords">getCoords()</a></dt>
<dd><p>Converts a mouse-click position to percentage coordinates relative to the
 image, clamping to the 5–95% range to keep buttons within visible bounds.</p>
</dd>
<dt><a href="#handleItemSelected">handleItemSelected()</a></dt>
<dd><p>Handles button selection — redirects to another category if a redirect
 is set, otherwise dims the closeup and opens the item picker for the selected button.</p>
</dd>
<dt><a href="#handleMouseMove">handleMouseMove()</a></dt>
<dd><p>Tracks the mouse position and rotates both cat pupils to face the cursor
 using atan2, bounded to a quarter of the eye container&#39;s radius.</p>
</dd>
</dl>

<a name="syncCopiedButtons"></a>

## syncCopiedButtons()
Deep-clones the buttons array so child components receive a new reference
 and re-render when disabled state changes.

**Kind**: global function  
<a name="getCoords"></a>

## getCoords()
Converts a mouse-click position to percentage coordinates relative to the
 image, clamping to the 5–95% range to keep buttons within visible bounds.

**Kind**: global function  
<a name="handleItemSelected"></a>

## handleItemSelected()
Handles button selection — redirects to another category if a redirect
 is set, otherwise dims the closeup and opens the item picker for the selected button.

**Kind**: global function  
<a name="handleMouseMove"></a>

## handleMouseMove()
Tracks the mouse position and rotates both cat pupils to face the cursor
 using atan2, bounded to a quarter of the eye container's radius.

**Kind**: global function  


## Files

- `ahaErlCloseup.css`
- `ahaErlCloseup.html`
- `ahaErlCloseup.js`
- `ahaErlCloseup.js-meta.xml`



[![SFDX-Hardis is provided by Cloudity](https://raw.githubusercontent.com/hardisgroupcom/sfdx-hardis/refs/heads/main/docs/assets/images/cloudity-banner.png)](https://cloudity.com?ref=sfdxhardis)

_Documentation generated with [sfdx-hardis](https://sfdx-hardis.cloudity.com), by [Cloudity](https://www.cloudity.com/) & [friends](https://github.com/hardisgroupcom/sfdx-hardis/graphs/contributors)_
