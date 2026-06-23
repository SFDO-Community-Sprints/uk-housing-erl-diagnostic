import { LightningElement, api } from 'lwc';

/**
 * @description Renders the guidance text associated with a repair category or SOR selection,
 * sanitising HTML encoding artefacts before display.
 */
export default class AhaErlAdvice extends LightningElement {
    @api guidanceText;
    @api defaultProfileOptions;

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    get cleanedGuidanceText() {
        if (this.guidanceText) {
            return this.guidanceText.replace(/Â/g, '');
        }
        return '';
    }
}