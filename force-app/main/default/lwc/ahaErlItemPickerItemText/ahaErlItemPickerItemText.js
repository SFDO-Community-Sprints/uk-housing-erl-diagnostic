import { LightningElement, api } from 'lwc';

/**
 * @description Presentational wrapper that renders the plain text content of a single item picker entry.
 */
export default class AhaErlItemPickerItemText extends LightningElement {
    @api text;
    @api defaultProfileOptions;

}