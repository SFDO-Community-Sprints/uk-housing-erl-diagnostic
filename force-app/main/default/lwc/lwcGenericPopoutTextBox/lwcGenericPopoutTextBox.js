import { LightningElement, api } from 'lwc';

/**
 * @description Lightweight popout panel that displays a body text string and emits a close
 * event when the user dismisses it.
 */
export default class lwcGenericPopoutTextBox extends LightningElement {
    @api bodyText;
    @api defaultProfileOptions; //ERL

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}