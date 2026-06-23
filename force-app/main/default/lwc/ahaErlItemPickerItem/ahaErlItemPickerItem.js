import { LightningElement, api, track } from 'lwc';
import removeSORfromCategory from '@salesforce/apex/AhaErlController.removeSORfromCategory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Renders a single selectable SOR entry in the item picker, displaying heading,
 * description, and code with location/quantity inputs, search-term highlighting, and edit-mode deletion.
 */
export default class AhaErlItemPickerItem extends LightningElement {
    @api editMode;
    @api sor;
    @api mode;
    @api filter; //for search mode only
    @api repairLocations;
    @api buttonsDisabled;
    @api itemListId;
    @api overrideAddButtonText;
    @api userEditMode;
    @api autoOpen;

    @track selectedSOR;
    @track thisCompAddClicked = false;

    @api defaultProfileOptions;
    @api allRepairProfiles;

    get getAddButtonText() {
        return this.overrideAddButtonText ? this.overrideAddButtonText : 'Add';
    }

    get getMiniEditSearchMode() {
        return this.mode === 'miniEditSearch';
    }

    get searchEditMode() {
        return this.mode === 'searchEdit';
    }

    get getSearchOrBrowseMode() {
        return this.mode === 'search' || this.mode === 'browse';
    }

    get getFilter() {
        return this.filter.toLowerCase().split(' ').filter(word => word);
    }

    get fullDescHighlightedText() {
        
        
        if (this.filter === undefined || this.filter === '') {
            return [{ text: this.selectedSOR.fullDescription, isMatch: false }];
        }
        return this.getHighlightedText(this.selectedSOR.fullDescription, this.getFilter);
    }

    get headingHighlightedText() {
        if (this.filter === undefined || this.filter === '') {
            return [{ text: this.selectedSOR.heading, isMatch: false }];
        }
        return this.getHighlightedText(this.selectedSOR.heading, this.getFilter);
    }

    get sorCodeHighlightedText() {
        if (this.filter === undefined || this.filter === '') {
            return [{ text: this.selectedSOR.sorCode, isMatch: false }];
        }
        return this.getHighlightedText(this.selectedSOR.sorCode, this.getFilter);
    }

    get Options() {
        let options = [];
        for (let key in this.repairLocations) {
            options.push({label: key, value: this.repairLocations[key]});
        }
        return options;
    }

    get getLocation() {
        return this.selectedSOR.location;
    }

    connectedCallback() {
        this.selectedSOR = JSON.parse(JSON.stringify(this.sor));
        if (this.autoOpen) {
            this.selectedSOR.selected = true;
        }
    }

    /** @description Splits text into character segments and marks ranges that match any filter
     *  word, then merges adjacent same-match segments for efficient rendering. */
    getHighlightedText(text, filterWords) {
        filterWords.sort((a, b) => b.length - a.length);
        const segments = text.split('').map(char => ({ text: char, isMatch: false }));
    
        filterWords.forEach(word => {
            let index = text.toLowerCase().indexOf(word);
    
            while (index !== -1) {
                // Mark the segments that match the current word
                for (let i = index; i < index + word.length; i++) {
                    segments[i].isMatch = true;
                }
    
                index = text.toLowerCase().indexOf(word, index + word.length);
            }
        });
    
        // Merge adjacent segments with the same `isMatch` value
        const mergedSegments = [];
        let currentSegment = segments[0];
    
        for (let i = 1; i < segments.length; i++) {
            const segment = segments[i];
    
            if (segment.isMatch === currentSegment.isMatch) {
                currentSegment.text += segment.text;
            } else {
                mergedSegments.push(currentSegment);
                currentSegment = { text: segment.text, isMatch: segment.isMatch };
            }
        }
    
        mergedSegments.push(currentSegment);
    
        return mergedSegments;
    }

    handleSORClickEdit() {
        this.dispatchEvent(new CustomEvent('rivsorselector__sorselectededit', {detail: this.selectedSOR, bubbles: true, composed: true}));
    }

    handleSORClickSearchEdit() {

    }

    handleEditedCategory() {
        this.dispatchEvent(new CustomEvent('categoryedited'));
    }

    spinnerOn() {
        this.dispatchEvent(new CustomEvent('spinneron'));
    }

    spinnerOff() {
        this.dispatchEvent(new CustomEvent('spinneroff'));
    }
    
    /** @description Resolves the selected location's display label, deselects the SOR, and
     *  dispatches it upstream as a confirmed selection. */
    handleSORSend() {
        this.selectedSOR.selected = false;
        this.selectedSOR.locationLabel = this.Options.find(location => location.value === this.getLocation).label;
        this.dispatchEvent(new CustomEvent('rivsorselector__sorselected', {detail: this.selectedSOR, bubbles: true, composed: true}));
        this.dispatchEvent(new CustomEvent('enablebuttons'));
    }

    handleSORClick() {
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: 'SOR EXPANDED:' + this.selectedSOR.heading
             , bubbles: true, composed: true }));
        this.dispatchEvent(new CustomEvent('disablebuttons', {detail: this.selectedSOR.id}));
        this.selectedSOR.selected = true;
    }

    @api
    handleCloseOtherButtons(event) {
        if (event !== this.selectedSOR.id) {
            this.selectedSOR.selected = false;
        }
    }

    handleCancelClick() {
        if (this.userEditMode || this.autoOpen) {
            this.dispatchEvent(new CustomEvent('closeuseredit'));
        } else {
            this.selectedSOR.selected = false;
        }
    }

    handleQuantityChange(event) {
        this.selectedSOR.quantity = event.currentTarget.value;
    }

    handleRepairLocationChange(event) {
        this.selectedSOR.location = event.currentTarget.value;
    }

    handleAddClick() {
        if (this.isInputValid()) {
            this.handleSORSend();
        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a location and enter a quantity greater than 0.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    /**
     * @description Removes this SOR from the parent item list category via Apex and fires a
     * category-edited event to trigger a data refresh.
     */
    handleDeleteClick() {
        removeSORfromCategory({sor: this.selectedSOR.id, categoryId: this.itemListId})
            .then(result => {
                let toast = new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'success'
                });
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }

    /** @description Runs constraint validation on all elements marked `.validate` and reports
     *  validity inline; returns false if any field is invalid. */
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
}