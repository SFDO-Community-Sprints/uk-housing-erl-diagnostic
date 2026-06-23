import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import AhaErlImages from '@salesforce/resourceUrl/AhaErlImages';
import IMAGE_FILE_TEXT_FIELD from '@salesforce/schema/AHA_ERL_Category__c.ImageFileText__c';
import RECORD_TYPE_NAME from '@salesforce/schema/AHA_ERL_Category__c.RecordTypeName__c';
import LAYOUT_LEFT from '@salesforce/schema/AHA_ERL_Category__c.Layout_Left__c';
import LAYOUT_TOP from '@salesforce/schema/AHA_ERL_Category__c.Layout_Top__c';
import LABEL from '@salesforce/schema/AHA_ERL_Category__c.Label__c'
import PARENT_IMAGE_FILE_TEXT from '@salesforce/schema/AHA_ERL_Category__c.ParentCategoryLookup__r.ImageFileText__c';
import updateCoords from '@salesforce/apex/AhaErlController.updateSORCategoryCoords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Previews a category image on a record page and allows admins to click to
 * position repair buttons, persisting coordinates via Apex.
 */
export default class AhaErlImagePreview extends LightningElement {
    @api recordId; // This gets the ID of the current record

    @wire(getRecord, { recordId: '$recordId', fields: [LABEL, IMAGE_FILE_TEXT_FIELD, RECORD_TYPE_NAME, LAYOUT_LEFT, LAYOUT_TOP, PARENT_IMAGE_FILE_TEXT]})
    record;

    @track tempChange = false;
    @track tempx = '';
    @track tempy = '';
    updateParams = {};
    @track updateSuccess = false;

    @api defaultProfileOptions;

    get isButton() {
        return this.record.data ? this.record.data.fields.RecordTypeName__c.value === 'RepairLocationButton' : false;
    }

    get getLabel() {
        return this.record.data ? this.record.data.fields.Label__c.value : '';
    }

    get imageFileText() {
        if (this.isButton) {
            return this.record.data ? getFieldValue(this.record.data, PARENT_IMAGE_FILE_TEXT) : '';
        } else {
            return this.record.data ? this.record.data.fields.ImageFileText__c.value : '';
        }
    }

    get image() {
        if (this.isButton || this.imageFileText) {
            return AhaErlImages + '/' + this.imageFileText.replaceAll(' ','');
        } else {
            return null;
        }
    }

    get getStyle() {
        let style = '';
        if (this.tempx != '' && this.tempy != '') {
            style = 'position: absolute;';
            style += 'left: ' + this.tempx + '; top: ' + this.tempy + ';';
        } else if (this.record.data.fields.Layout_Left__c.value != null && this.record.data.fields.Layout_Top__c.value != null) {
            style = 'position: absolute;';
            style += 'left: ' + this.record.data.fields.Layout_Left__c.value + '; top: ' + this.record.data.fields.Layout_Top__c.value + ';';
        }
        
        return style;
    }

    /** @description Converts a click position to percentage coordinates relative to the image,
     *  clamping to 5–95% bounds, and stages them for saving. */
    getCoords(event) {
        if (!this.isButton) {
            return;
        }
        let rect = event.target.getBoundingClientRect();
        let x = event.clientX - rect.left;
        let y = event.clientY - rect.top;
        let xPercent = (x / rect.width) * 100;
        let yPercent = (y / rect.height) * 100;
        xPercent = Math.round(xPercent * 10) / 10;
        yPercent = Math.round(yPercent * 10) / 10;
        this.tempx = xPercent + '%';
        this.tempy = yPercent + '%';
        //ignore if xPercent or yPercent is less than 5 or greater than 95
        if (xPercent < 5 || xPercent > 95 || yPercent < 5 || yPercent > 95) {
            this.tempx = '';
            this.tempy = '';
        } else {
            this.tempChange = true;
            this.updateParams = {id : this.recordId, x: this.tempx, y: this.tempy};
            
        }
    }

    /**
     * @description Persists the button's new X/Y percentage coordinates to the Salesforce record
     * via Apex and notifies the record cache to refresh the wire data.
     */
    saveCoords() {
        updateCoords({params: this.updateParams}).then(result => {
            this.updateSuccess = result;
            if (this.updateSuccess) {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated successfully',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                getRecordNotifyChange([{recordId: this.recordId}]);
            }
        });
        this.tempChange = false;
    }

    cancelCoords() {
        this.tempx = '';
        this.tempy = '';
        this.tempChange = false;
    }

}