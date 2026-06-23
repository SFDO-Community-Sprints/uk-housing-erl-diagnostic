import { LightningElement, api, track } from 'lwc';
import getSORCategory from '@salesforce/apex/AhaErlController.getSORCategory';
import AhaErlIcons from '@salesforce/resourceUrl/AhaErlIcons';
import AhaErlImages from '@salesforce/resourceUrl/AhaErlImages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Renders a single repair category's subcategories and closeup buttons;
 * handles navigation between categories in the SOR hierarchy and toggles repair advice display.
 */
export default class AhaErlCategory extends LightningElement {
    @api repairProfile;
    @api guidedUser;
    @api allRepairProfiles;
    @api category;
    @api repairLocations;
    @api editMode = false;
    @api displayTabs;
    @api myAhaErlMode;
    @track selectedCategory;
    categories = [];
    @track displayedCategories = [];
    @track isCloseup = false;
    @track isEmpty = false;
    @track closeupGuidance = false;
    @track guidanceText = '';
    @track hasGuidance = false;

    get cleanedGuidanceText() {
        if (this.guidanceText) {
            return this.guidanceText.replace(/Â/g, '');
        }
        return '';
    }

    @api defaultProfileOptions;

    buttonClick = false;

    get getGuidanceButtonText() {
        return this.closeupGuidance ? 'Close Repair Advice' : 'Repair Advice';
    }

    get getIsEmptyEditMode() {
        if (this.isEmpty && this.editMode) {
            return true;
        }
        return false;
    }

    get getIsCategoryPicked() {
        return this.selectedCategory !== undefined && this.selectedCategory !== null;
    }

    get getIsCategortNotPicked() {
        return this.selectedCategory === undefined || this.selectedCategory === null;
    }

    /**
     * @description Fetches the child categories for the current category from Apex on component load.
     */
    connectedCallback() {
        if (this.category !== undefined && this.category !== null) {
            getSORCategory({id: this.category, profileName: this.repairProfile}).then((data) => {
                this.setCategories(data);
            });
        }
    }

    /**
     * @description Fetches child categories for a redirect target category from Apex when
     * the user navigates to a linked category.
     */
    handleRedirectCategory(event) {
        getSORCategory({id: event.detail , profileName: this.repairProfile}).then((data) => {
            this.setCategories(data);
        });
    }

    /**
     * @description Re-fetches the current category's children from Apex after an admin edit.
     */
    handleEditedCategory() {
        this.spinnerOn();
        getSORCategory({id: this.category, profileName: this.repairProfile}).then((data) => {
            this.setCategories(data);
        });
    }

    /** @description Processes the raw Apex category response — routes to closeup mode for
     *  RepairLocationCloseup record types or populates the subcategory grid otherwise,
     *  filtering by guided mode. */
    setCategories(data) {
        if (data === null || data.length === 0) {
            this.isEmpty = true;
            this.categories = [];
            return;
        }

        if (data[0].recordType === 'RepairLocationCloseup') {
            this.isCloseup = true;
            this.guidanceText = data[0].guidance;
            this.hasGuidance = data[0].hasGuidance;
            data[0].ImageUrl = AhaErlImages + '/' + data[0].imageFileText;
            if (data.length > 1) {
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Closeup category has more than one record. Only the first closeup will be shown. Please inform the administrator of this error.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            }
            data = data.slice(0, 1);
        } else {
            data.forEach((category) => {
                category.ImageUrl = AhaErlIcons + '/' + category.imageFileText;
            });
            this.displayedCategories = data.filter((category) => {
                return (category.isGuided === this.guidedUser);
            });
        }

        this.categories = data;
        this.markActiveCategories();
        this.spinnerOff();
    }

    handleCategoryTabClick(event) {
        if (this.buttonClick) {
            this.buttonClick = false;
            return;
        }
        this.selectedCategory = event.currentTarget.dataset.id;
        this.markActiveCategories();
        const selectedCategoryLabel = this.categories.find((category) => category.id === this.selectedCategory).label;
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: selectedCategoryLabel , bubbles: true, composed: true }));
    }

    handleCategoryButtonClick(event) {
        this.buttonClick = true;
        this.selectedCategory = event.currentTarget.dataset.id;
        this.markActiveCategories();
        const selectedCategoryLabel = this.categories.find((category) => category.id === this.selectedCategory).label;
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: selectedCategoryLabel , bubbles: true, composed: true }));
    }

    handleBack() {
        this.selectedCategory = undefined;
        this.markActiveCategories();
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: 'BACK' , bubbles: true, composed: true }));
        this.buttonClick = true;
    }

    markActiveCategories() {
        this.categories = (this.categories || []).map((category) => {
            return {
                ...category,
                isActive: this.selectedCategory !== undefined && this.selectedCategory !== null && category.id === this.selectedCategory
            };
        });
    }

    handleBackClick() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleGuidanceClick() {
        this.closeupGuidance = !this.closeupGuidance;
    }

    handleGuidanceClose() {
        this.closeupGuidance = false;
    }

    spinnerOn() {
        this.dispatchEvent(new CustomEvent('spinneron'));
    }

    spinnerOff() {
        this.dispatchEvent(new CustomEvent('spinneroff'));
    }

}