import { LightningElement, api, track } from 'lwc';
import getSORsForButton from '@salesforce/apex/AhaErlController.getSORsForButton';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Displays the selectable SOR items for a chosen repair category button,
 * supporting both guided (problem-first) and standard (SOR-first) selection modes.
 */
export default class AhaErlItemPicker extends LightningElement {

    @api repairProfile;
    @api guidedUser;
    @api editMode;
    @api selectedItem;
    @api repairLocations;
    @api allRepairProfiles;
    @track itemLists = [];
    @track buttonsDisabled = false;
    @track selectedProblem;
    @track isSpinnerOn = true;
    location;
    selectedSOR;
    guidedModeDetails = '';

    @api defaultProfileOptions;

    get isProblemSelected() {
        return this.selectedProblem !== undefined;
    }

    get autoOpenProblemSOR() {
        return this.selectedProblem && this.selectedProblem.sorList.length === 1;
    }

    get guidedModeAndEditMode() {
        return this.guidedUser && this.editMode;
    }

    get isGuidedModeNotEditing() {
        //also if selectedProblem.messages is not empty
        return this.guidedUser && !this.editMode && this.selectedProblem && this.selectedProblem.messages && this.selectedProblem.messages.length == 0;
    }

    get notGuidedMode() {
        return !this.guidedUser || this.editMode;
    }

    get absoluteNotGuidedMode() {
        return !this.guidedUser;
    }

    get repairOptions() {
        let options = [];
        let notSureOption = null;
    
        for (let key in this.repairLocations) {
            let label = key.substring(6);
            let value = this.repairLocations[key];
    
            if (value === "UNK") {
                notSureOption = { label: "Not Sure", value: value };
            } else {
                options.push({ label: label, value: value });
            }
        }
    
        if (notSureOption) {
            options.unshift(notSureOption); // Add "Not Sure" as the first option
        }
    
        return options;
    }

    /**
     * @description Fetches the SOR item lists for the selected category button from Apex on load.
     */
    connectedCallback() {
        getSORsForButton({id: this.selectedItem, profileName: this.repairProfile})
            .then(result => {
                this.itemLists = result;
                this.isSpinnerOn = false;
            })
            .catch(error => {
                
            });
    }

    /**
     * @description Re-fetches SOR item lists from Apex after an admin edit, restoring the
     * previously selected problem if it still exists.
     */
    handleEditedCategory() {
        const selectedProblemId = this.selectedProblem ? this.selectedProblem.id : null;
        this.itemLists = [];
        this.isSpinnerOn = true;
        getSORsForButton({id: this.selectedItem, profileName: this.repairProfile})
            .then(result => {
                this.itemLists = result;
                if (selectedProblemId) {
                    let refreshedProblem;
                    this.itemLists.some((itemList) => {
                        refreshedProblem = itemList.subCategories.find((subcategory) => subcategory.id === selectedProblemId);
                        return !!refreshedProblem;
                    });
                    this.selectedProblem = refreshedProblem;
                }
                this.isSpinnerOn = false;
            })
            .catch(error => {
                
            });
    }

    handleClickSubCategory(event) {
        let subc = event.currentTarget.dataset.id;
        let ilist = event.currentTarget.dataset.itemlistid;
        this.selectedProblem = this.itemLists.find(itemlist => itemlist.id === ilist).subCategories.find(subcategory => subcategory.id === subc);
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: this.selectedProblem.label, bubbles: true, composed: true }));
    }

    handleSubCategoryBack() {
        this.selectedProblem = undefined;
        this.buttonsDisabled = false;
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: 'BACK' , bubbles: true, composed: true }));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleLocationChange(event) {
        this.location = event.detail.value;
        //this commented event is intended to set the location as default for the picklist in any further selected repairs. Commented because not sure if we want it to do this.
        // this.dispatchEvent(new CustomEvent('locationchange', {detail: event.detail}));
    }

    /** @description Validates the required free-text details field, attaches the selected
     *  location to each SOR, then dispatches the guided-submit event up to the picker. */
    handleGuidedSubmit() {
        if (!this.guidedModeDetails || !this.guidedModeDetails.trim()) {
            const textarea = this.template.querySelector('lightning-textarea');
            if (textarea) {
                textarea.setCustomValidity('This information is required.');
                textarea.reportValidity();
            }
            // Show toast to user
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'More Details are Required',
                    message: 'Please provide more details about the repair.',
                    variant: 'error'
                })
            );
            return;
        } else {
            const textarea = this.template.querySelector('lightning-textarea');
            if (textarea) {
                textarea.setCustomValidity('');
                textarea.reportValidity();
            }
        }
        this.selectedProblem.sorList.forEach(sor => {
            sor.location = this.location;
        });
        this.dispatchEvent(new CustomEvent('rivsorselector__guidedsubmit', 
            {detail: {selectedProblem: this.selectedProblem, 
                      guidedModeDetails: this.guidedModeDetails},
             bubbles: true, 
             composed: true
            })
        );
    }

    handleGuidedModeDetailsChange(event) {
        this.guidedModeDetails = event.detail.value;
    }

    disableButtons(event) {
        this.template.querySelectorAll('c-aha-erl-item-picker-item').forEach(item => {
            item.handleCloseOtherButtons(event.detail);
        });
    }

    enableButtons() {
        this.buttonsDisabled = false;
    }

    handleSpinnerOn() {
        this.isSpinnerOn = true;
    }

    handleSpinnerOff() {
        this.isSpinnerOn = false;
    }

}