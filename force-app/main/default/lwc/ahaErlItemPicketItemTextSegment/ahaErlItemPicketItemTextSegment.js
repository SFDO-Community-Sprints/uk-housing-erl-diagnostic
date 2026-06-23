import { LightningElement, api } from 'lwc';

/**
 * @description Renders a single text segment within an item picker entry, applying highlight
 * styling to segments that match the active search filter.
 */
export default class AhaErlItemPicketItemTextSegment extends LightningElement {
    @api segment;
    @api defaultProfileOptions;

    get segmentClass() {
        let highlight = this.segment.isMatch ? 'highlight' : '';
        let hyphenate = this.segment.text.length === 6 ? '' : 'slds-hyphenate';
        return `${highlight} ${hyphenate}`;
    }
}