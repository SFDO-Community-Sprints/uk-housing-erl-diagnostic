import { LightningElement, api, track } from 'lwc';
import getAllSORsWithAssignment from '@salesforce/apex/AhaErlController.getAllSORsWithAssignment';
import addSORAssignment from '@salesforce/apex/AhaErlController.addSORAssignment';
import removeSORAssignment from '@salesforce/apex/AhaErlController.removeSORAssignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Admin tool for assigning and unassigning SOR codes to a named repair profile,
 * with search, assignment-status filtering, and pagination.
 */
export default class AhaErlProfileAssignment extends LightningElement {
    @api profileName;
    @track sors = [];
    @track filteredSors = [];
    @track currentPage = 1;
    @track pageSize = 25;
    @track totalPages = 0;
    @track isLoading = false;
    @track searchKey = '';
    @track showAssignedOnly = false;
    @track showUnassignedOnly = false;

    fullDatasetCount;
    filteredDatasetCount;
    assignedSORCount;
    unassignedSORCount;

    connectedCallback() {
        this.fetchSORs();
    }

    /**
     * @description Loads all SOR codes with their current assignment status for the given
     * profile from Apex, then applies client-side filtering.
     */
    fetchSORs() {
        this.isLoading = true;
        getAllSORsWithAssignment({ profileName: this.profileName })
            .then(result => {
                this.sors = result;
                this.filteredSors = result;
                this.totalPages = Math.ceil(this.filteredSors.length / this.pageSize);
                this.isLoading = false;
                this.filterSORs();
            })
            .catch(error => {
                console.error('Error fetching SORs:', error);
                this.isLoading = false;
            });
    }

    get paginatedSORs() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        return this.filteredSors.slice(start, end);
    }

    get getDisabledPrevious() {
        return this.currentPage === 1;
    }

    get getDisabledNext() {
        return this.currentPage === this.totalPages;
    }

    get hasFilteredResults() {
        return this.filteredSors && this.filteredSors.length > 0;
    }

    get isLoadingOrNoResults() {
        return this.isLoading || !this.hasFilteredResults;
    }

    handleBack() {
        const backEvent = new CustomEvent('back');
        this.dispatchEvent(backEvent);
    }

    /** @description Copies the current filtered result set to clipboard in tab-delimited format
     *  so it can be pasted directly into Excel. */
    handleCopyToClipboard() {
        try {
            let text = 'SOR Code\tHeading\tDescription\tAssigned\n';
            this.filteredSors.forEach((sor) => {
                text += `${sor.sorCode || ''}\t`;
                text += `${sor.heading || ''}\t`;
                text += `${sor.fullDescription || ''}\t`;
                text += `${sor.selected ? 'Yes' : 'No'}\n`;
            });

            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();

            const successful = document.execCommand('copy');
            document.body.removeChild(textArea);

            if (successful) {
                this.showToast('Success', 'Data copied to clipboard.', 'success');
            } else {
                this.showToast('Error', 'Failed to copy to clipboard.', 'error');
            }
        } catch (error) {
            console.error('Copy to clipboard failed:', error);
            this.showToast('Error', 'Failed to copy to clipboard.', 'error');
        }
    }

    /** @description Downloads the current filtered result set as a CSV file for spreadsheet use. */
    handleDownloadCsv() {
        try {
            const rows = [
                ['SOR Code', 'Heading', 'Description', 'Assigned']
            ];

            this.filteredSors.forEach((sor) => {
                rows.push([
                    sor.sorCode || '',
                    sor.heading || '',
                    sor.fullDescription || '',
                    sor.selected ? 'Yes' : 'No'
                ]);
            });

            const csvContent = rows
                .map((row) => row.map((cell) => this.escapeCsvCell(cell)).join(','))
                .join('\n');

            const url = `data:text/plain;charset=utf-8,${encodeURIComponent(csvContent)}`;
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', this.buildCsvFileName());
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showToast('Success', 'CSV downloaded successfully.', 'success');
        } catch (error) {
            console.error('CSV download failed:', error);
            this.showToast('Error', 'Failed to download CSV.', 'error');
        }
    }

    escapeCsvCell(value) {
        const stringValue = String(value ?? '');
        const escaped = stringValue.replace(/"/g, '""');
        return `"${escaped}"`;
    }

    buildCsvFileName() {
        const safeProfile = (this.profileName || 'profile').replace(/[^a-zA-Z0-9_-]/g, '_');
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        return `erl-profile-assignment-${safeProfile}-${timestamp}.csv`;
    }

    /**
     * @description Calls Apex to add or remove the SOR assignment for the profile depending
     * on whether the checkbox was checked or unchecked.
     */
    handleSORCheckboxChange(event) {
        const sorId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.sors = this.sors.map(sor => {
            if (sor.id === sorId) {
                return { ...sor, selected: isChecked };
            }
            return sor;
        });
        this.filteredSors = this.filteredSors.map(sor => {
            if (sor.id === sorId) {
                return { ...sor, selected: isChecked };
            }
            return sor;
        });

        if (isChecked) {
            addSORAssignment({ profileName: this.profileName, sorId: sorId })
                .then(result => {
                    if (result.includes('error')) {
                        this.showToast('Error', result, 'error');
                    } else {
                        this.showToast('Success', 'SOR assigned successfully.', 'success');
                    }
                })
                .catch(error => {
                    console.error('Error adding SOR assignment:', error);
                    this.showToast('Error', 'Error adding SOR assignment.', 'error');
                });
        } else {
            removeSORAssignment({ profileName: this.profileName, sorId: sorId })
                .then(result => {
                    if (result.includes('error')) {
                        this.showToast('Error', result, 'error');
                    } else {
                        this.showToast('Success', 'SOR unassigned successfully.', 'success');
                    }
                })
                .catch(error => {
                    console.error('Error removing SOR assignment:', error);
                    this.showToast('Error', 'Error removing SOR assignment.', 'error');
                });
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.filterSORs();
    }

    handleShowAssignedOnlyChange(event) {
        this.showAssignedOnly = event.target.checked;
        if (this.showAssignedOnly) {
            this.showUnassignedOnly = false;
        }
        this.filterSORs();
    }

    handleShowUnassignedOnlyChange(event) {
        this.showUnassignedOnly = event.target.checked;
        if (this.showUnassignedOnly) {
            this.showAssignedOnly = false;
        }
        this.filterSORs();
    }

    /** @description Filters the full SOR list by search key, assigned-only, and unassigned-only
     *  flags, then recalculates page count and assignment/unassignment totals. */
    filterSORs() {
        this.filteredSors = this.sors.filter(sor => {
            const matchesSearchKey = sor.sorCode.toLowerCase().includes(this.searchKey) ||
                                     sor.heading.toLowerCase().includes(this.searchKey) ||
                                     sor.fullDescription.toLowerCase().includes(this.searchKey);
            const matchesAssignedFilter = !this.showAssignedOnly || sor.selected;
            const matchesUnassignedFilter = !this.showUnassignedOnly || !sor.selected;
            return matchesSearchKey && matchesAssignedFilter && matchesUnassignedFilter;
        });
        this.totalPages = Math.ceil(this.filteredSors.length / this.pageSize);
        this.currentPage = 1;
        this.fullDatasetCount = this.sors.length
        this.filteredDatasetCount = this.filteredSors.length
        this.assignedSORCount = this.sors.filter(sor => sor.selected).length
        this.unassignedSORCount = this.sors.filter(sor => !sor.selected).length
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}