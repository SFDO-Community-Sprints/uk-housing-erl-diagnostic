import { LightningElement, api, track } from 'lwc';
import updateSORCategoryCoords from '@salesforce/apex/AhaErlController.updateSORCategoryCoords';

/**
 * @description Renders a positioned repair category button overlaid on a closeup image;
 * supports drag-to-reposition in edit mode, persisting updated coordinates via Apex.
 */
export default class AhaErlItemButton extends LightningElement {
    @api allRepairProfiles;
    @api guidedUser;
    @api button;
    @api editMode = false;
    @api moveparams;
    @api disableMove = false;
    @track moveMode = false;
    @track pendingLayoutLeft;
    @track pendingLayoutTop;

    @api defaultProfileOptions;

    get getStyle() {
        let style = '';
        if (this.moveMode && this.moveparams !== undefined && this.moveparams !== null && this.moveparams.x !== undefined && this.moveparams.y !== undefined) {
            style = 'position: absolute;';
            style += 'left: ' + this.moveparams.x + '; top: ' + this.moveparams.y + ';';
        } else if (this.pendingLayoutLeft != null && this.pendingLayoutTop != null) {
            style = 'position: absolute;';
            style += 'left: ' + this.pendingLayoutLeft + '; top: ' + this.pendingLayoutTop + ';';
        } else if (this.button.layoutLeft != null && this.button.layoutTop != null) {
            style = 'position: absolute;';
            style += 'left: ' + this.button.layoutLeft + '; top: ' + this.button.layoutTop + ';';
        }
        return style;
    }

    get getMoveIcon() {
        return this.moveMode ? 'utility:save' : 'utility:move';
    }

    get moveDisabled() {
        if ((this.disableMove == true && this.moveMode == false) || this.button.disabled == true) {
            return true;
        } else {
            return false;
        }
    }

    get getButtonLabel() {
        if (this.editMode) {
            return this.button.editModeLabel;
        } else {
            return this.button.label;
        }
    }

    get getMoveVariant() {
        return this.moveMode ? 'brand' : 'border-filled';
    }

    /**
     * @description Toggles move mode; when exiting move mode with new coordinates, persists the
     * updated button position to Salesforce via Apex with an optimistic local render.
     */
    handleMoveMode() {
        if (!this.editMode) {
            return;
        }
        this.moveMode = !this.moveMode;
        if (this.moveMode) {
            this.dispatchEvent(new CustomEvent('movemode', {detail: true}));
        } else {
            if (!this.moveparams || this.moveparams.x === undefined || this.moveparams.y === undefined) {
                this.dispatchEvent(new CustomEvent('movemode', {detail: false}));
                return;
            }

            // Optimistically render moved coordinates until parent refresh returns.
            this.pendingLayoutLeft = this.moveparams.x;
            this.pendingLayoutTop = this.moveparams.y;

            let updateparams = {id: this.button.id, x: this.moveparams.x, y: this.moveparams.y};
            updateSORCategoryCoords({params: updateparams}).then(result => {
                this.dispatchEvent(new CustomEvent('movemode', {detail: false}));
                this.dispatchEvent(new CustomEvent('categoryedited'));
            }).catch(error => {
                // Roll back optimistic placement on save failure.
                this.pendingLayoutLeft = null;
                this.pendingLayoutTop = null;
                //only displayed to admins
                console.error('Error updating SOR category coords: ', error);
            });
        }
    }

    handleEditedCategory() {
        this.dispatchEvent(new CustomEvent('categoryedited'));
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('itemselected', {detail: this.button}));
    }
    
}