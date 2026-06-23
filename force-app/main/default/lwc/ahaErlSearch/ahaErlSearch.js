import { LightningElement, api, track } from 'lwc';
import getAllSORsForSearch from '@salesforce/apex/AhaErlController.getAllSORsForSearch';

/**
 * @description Provides full-text search across SOR codes and descriptions for a given repair
 * profile, with client-side filtering, pagination, and location override support.
 */
export default class AhaErlSearch extends LightningElement {
    @api repairLocations;
    @api profile;
    @api editMode;
    @api miniSearch;
    @api searchEditMode;
    @track spinnerOn = false;

    @track filter = '';
    sendFilter = '';

    allSORs = [];
    @track filteredSORs = [];
    currentPage = 1;
    pageSize = 10;
    totalPages = 0;

    overrideLocation;
    buttonsDisabled;

    @api defaultProfileOptions;
    @api allRepairProfiles;

    get getDisplayedSors() {
        return this.filteredSORs.slice((this.currentPage - 1) * this.pageSize, this.currentPage * this.pageSize);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get getFirstPageLabel() {
        if (this.miniSearch) {
            return '|<';
        }
        return 'First';
    }

    get getPrevPageLabel() {
        if (this.miniSearch) {
            return '<';
        }
        return 'Prev';
    }

    get getNextPageLabel() {
        if (this.miniSearch) {
            return '>';
        }
        return 'Next';
    }

    get getLastPageLabel() {
        if (this.miniSearch) {
            return '>|';
        }
        return 'Last';
    }

    /**
     * @description Loads the full list of SOR codes for the current profile from Apex on
     * component init; subsequent filtering is handled client-side.
     */
    connectedCallback() {
        this.spinnerOn = true;
        getAllSORsForSearch({profile: this.profile}).then((data) => {
            this.spinnerOn = false;
            this.allSORs = data;
            this.totalPages = Math.ceil(this.allSORs.length / this.pageSize);
            this.filteredSORs = this.allSORs;
        }).catch((error) => {
            this.spinnerOn = false;
            console.error('Error fetching SORs', error);
        });
    }

    handleFilterChange(event) {
        if (this.debounceTimeout) {
            clearTimeout(this.debounceTimeout);
        }
        this.filter = event.currentTarget.value;
        this.debounceTimeout = setTimeout(() => {
            this.sendFilter = this.filter;
            this.filterResults();
        }, 300);
    }

    /** @description Filters the full SOR list client-side using multi-word AND logic across
     *  sorCode, heading, and fullDescription, then resets pagination. */
    filterResults() {
        if (this.filter === undefined || this.filter === '') {
            this.filteredSORs = this.allSORs;
            this.totalPages = Math.ceil(this.filteredSORs.length / this.pageSize);
            this.currentPage = 1;
            return;
        }
    
        const filterWords = this.filter.toLowerCase().split(' ').filter(word => word);
    
        this.filteredSORs = this.allSORs.filter(sor => {
            const searchableText = (sor.sorCode + ' ' + sor.heading + ' ' + sor.fullDescription).toLowerCase();
            return filterWords.every(word => searchableText.includes(word));
        });
    
        this.totalPages = Math.ceil(this.filteredSORs.length / this.pageSize);
        this.currentPage = 1;
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleFirstPage() {
        this.currentPage = 1;
    }

    handleLastPage() {
        this.currentPage = this.totalPages;
    }

    handleLocationChange(event) {
        this.overrideLocation = event.detail;
        //this.dispatchEvent(new CustomEvent('locationchange', {detail: event.detail}));
    }

    disableButtons() {
        this.buttonsDisabled = true;
    }

    enableButtons() {
        this.buttonsDisabled = false;
    }

}