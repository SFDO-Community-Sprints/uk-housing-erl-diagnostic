import { LightningElement, api } from 'lwc';

/**
 * @description Renders message-type SOR content as sanitised HTML within the item picker,
 * stripping encoding artefacts before injecting into the DOM.
 */
export default class AhaErlItemPickerMessage extends LightningElement {
    @api message;
    @api defaultProfileOptions;

    get cleanedMessage() {
        if (this.message) {
            return this.message.replace(/Â/g, '');
        }
        return '';
    }

    renderedCallback() {
        this.template.querySelector('.riv-message').innerHTML = this.cleanedMessage;
    }
}