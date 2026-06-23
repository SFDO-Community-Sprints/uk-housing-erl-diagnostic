import { LightningElement, api, track } from 'lwc';
import LwcGenericModal from 'c/lwcGenericModal';

/**
 * @description Displays a single confirmed SOR selection in the summary list with remove and
 * inline-edit actions; uses a modal dialog to confirm deletion.
 */
export default class AhaErlPickedItem extends LightningElement {
    @api sor;
    @api repairLocations;
    @track isEditSOR = false;
    selectedSOR;

    @api defaultProfileOptions;

    disableButtonsConst = true;

    /** @description Opens a confirmation modal before dispatching the delete event, showing
     *  the SOR code and description so the user can confirm the correct item. */
    handleDeleteSorButton() {
        LwcGenericModal.open({
            size: 'small',
            header: 'Remove Selected SOR',
            content: 'Are you sure you want to remove this SOR from your selected list? <br/><br/>SOR: <strong>' + this.sor.sorCode + '</strong><br/>Description: ' + this.sor.fullDescription,
            displayOkButton: true,
            okButton: {label: 'Remove', variant: 'destructive'},
            displayCancelButton: true,
            cancelButton: {label: 'Cancel', variant: 'neutral'}
        }).then(result => {
            if (result) {
                this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: 'REMOVE SOR: ' + this.sor.sorCode, bubbles: true, composed: true }));
                this.deleteSor();
            }
        });
    }

    deleteSor() {
        this.dispatchEvent(new CustomEvent('deletesor', {
            detail: this.sor
        }));
    }

    handleEditSorButton() {
        this.selectedSOR = JSON.parse(JSON.stringify(this.sor));
        this.selectedSOR.selected = true;
        this.isEditSOR = true;
    }
    
    handleCloseEdit() {
        this.isEditSOR = false;
    }

    handleSorEdit(event) {
        this.selectedSOR = event.detail;
        this.dispatchEvent(new CustomEvent('soredit', {
            detail: this.selectedSOR
        }));
        this.isEditSOR = false;
    }

    handleSorEditClose() {
        this.isEditSOR = false;
    }
}