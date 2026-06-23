import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSORHierarchyData from '@salesforce/apex/AhaErlHierarchyController.getSORHierarchyData';
import getProfileOptions from '@salesforce/apex/AhaErlHierarchyController.getProfileOptions';

const COLUMNS = [
    { 
        label: 'SOR Code', 
        fieldName: 'sorCode', 
        type: 'text',
        sortable: true,
        initialWidth: 150
    },
    { 
        label: 'Description', 
        fieldName: 'sorHeadingText', 
        type: 'text',
        sortable: true,
        wrapText: true,
        initialWidth: 300
    },
    { 
        label: 'Category Path', 
        fieldName: 'categoryPath', 
        type: 'text',
        sortable: true,
        wrapText: true
    },
    { 
        label: 'Accessible', 
        fieldName: 'isAccessible', 
        type: 'boolean',
        sortable: true,
        initialWidth: 120,
        cellAttributes: { 
            class: { fieldName: 'accessibilityClass' }
        }
    }
];

/**
 * @description Read-only tabular view of the full SOR hierarchy for a selected repair profile,
 * with search, accessibility filtering, sortable columns, and clipboard export.
 */
export default class AhaErlHierarchyViewer extends LightningElement {
    @track selectedProfile = '';
    @track hierarchyData = [];
    @track filteredData = [];
    @track searchTerm = '';
    @track showOnlyAccessible = true;
    @track includeCloseups = false;
    @track isLoading = false;
    @track error;
    
    columns = COLUMNS;
    profileOptions = [];
    
    sortedBy;
    sortedDirection = 'asc';

    /**
     * @description Wire handler that fetches the list of repair profile options from Apex;
     * auto-selects the first profile and triggers a hierarchy data load when results arrive.
     */
    @wire(getProfileOptions)
    wiredProfiles({ error, data }) {
        if (data) {
            this.profileOptions = data.map(option => ({
                label: option.label,
                value: option.value
            }));
            
            // Auto-select first profile if available
            if (this.profileOptions.length > 0 && !this.selectedProfile) {
                this.selectedProfile = this.profileOptions[0].value;
                this.loadHierarchyData();
            }
        } else if (error) {
            this.error = error;
            console.error('Error loading profiles:', error);
        }
    }

    handleProfileChange(event) {
        this.selectedProfile = event.detail.value;
        this.loadHierarchyData();
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.filterData();
    }

    handleAccessibilityFilterChange(event) {
        this.showOnlyAccessible = event.target.checked;
        console.log('Checkbox changed to:', this.showOnlyAccessible);
        console.log('Total hierarchyData:', this.hierarchyData.length);
        this.filterData();
        console.log('Filtered to:', this.filteredData.length);
    }

    handleCloseupFilterChange(event) {
        this.includeCloseups = event.target.checked;
        this.loadHierarchyData();
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    /** @description Builds a tab-delimited string of the current filtered data and writes it
     *  to the clipboard, formatted for direct paste into Excel. */
    handleCopyToClipboard() {
        try {
            // Create tab-delimited text for Excel
            let text = 'SOR Code\tDescription\tCategory Path\tAccessible\n';
            
            this.filteredData.forEach(item => {
                text += `${item.sorCode || ''}\t`;
                text += `${item.sorHeadingText || ''}\t`;
                text += `${item.categoryPath || ''}\t`;
                text += `${item.isAccessible ? 'Yes' : 'No'}\n`;
            });
            
            // Create a temporary textarea element to copy text
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            
            try {
                const successful = document.execCommand('copy');
                document.body.removeChild(textArea);
                
                if (successful) {
                    this.showToast('Success', 'Data copied to clipboard! You can now paste into Excel.', 'success');
                } else {
                    this.showToast('Error', 'Failed to copy to clipboard', 'error');
                }
            } catch (err) {
                document.body.removeChild(textArea);
                console.error('Failed to copy:', err);
                this.showToast('Error', 'Failed to copy to clipboard', 'error');
            }
        } catch (error) {
            console.error('Copy error:', error);
            this.showToast('Error', 'Failed to copy to clipboard', 'error');
        }
    }

    /** @description Downloads the current filtered dataset as a CSV file so it can be opened
     *  directly in Excel or any spreadsheet tool. */
    handleDownloadCsv() {
        try {
            const csvRows = [
                ['SOR Code', 'Description', 'Category Path', 'Accessible']
            ];

            this.filteredData.forEach((item) => {
                csvRows.push([
                    item.sorCode || '',
                    item.sorHeadingText || '',
                    item.categoryPath || '',
                    item.isAccessible ? 'Yes' : 'No'
                ]);
            });

            const csvContent = csvRows
                .map((row) => row.map((cell) => this.escapeCsvCell(cell)).join(','))
                .join('\n');

            // Use a plain text data URI for maximum compatibility in Salesforce containers.
            const url = `data:text/plain;charset=utf-8,${encodeURIComponent(csvContent)}`;
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', this.buildCsvFileName());
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showToast('Success', 'CSV downloaded successfully.', 'success');
        } catch (error) {
            console.error('CSV download error:', error);
            this.showToast('Error', 'Failed to download CSV file', 'error');
        }
    }

    escapeCsvCell(value) {
        const stringValue = String(value ?? '');
        const escaped = stringValue.replace(/"/g, '""');
        return `"${escaped}"`;
    }

    buildCsvFileName() {
        const safeProfile = (this.selectedProfile || 'ERL').replace(/[^a-zA-Z0-9_-]/g, '_');
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        return `erl-hierarchy-${safeProfile}-${timestamp}.csv`;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /**
     * @description Fetches the full SOR hierarchy data for the selected profile from Apex,
     * including an optional closeup filter, then applies client-side filtering.
     */
    loadHierarchyData() {
        if (!this.selectedProfile) {
            return;
        }

        this.isLoading = true;
        this.error = undefined;

        getSORHierarchyData({ 
            profileName: this.selectedProfile,
            includeCloseups: this.includeCloseups
        })
            .then(result => {
                // Add CSS class for accessibility styling and unique key
                this.hierarchyData = result.map((item, index) => ({
                    ...item,
                    uniqueKey: `${item.sorId}-${item.categoryId}-${index}`,
                    accessibilityClass: item.isAccessible ? '' : 'slds-text-color_error'
                }));
                this.filterData();
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.hierarchyData = [];
                this.filteredData = [];
                this.isLoading = false;
                console.error('Error loading hierarchy data:', error);
            });
    }

    /** @description Applies the active search term and accessibility filter to hierarchyData,
     *  then re-applies any active column sort. */
    filterData() {
        let filtered = [...this.hierarchyData];

        // Apply search filter
        if (this.searchTerm) {
            filtered = filtered.filter(item => {
                return (
                    (item.sorCode && item.sorCode.toLowerCase().includes(this.searchTerm)) ||
                    (item.sorHeadingText && item.sorHeadingText.toLowerCase().includes(this.searchTerm)) ||
                    (item.categoryPath && item.categoryPath.toLowerCase().includes(this.searchTerm))
                );
            });
        }

        // Apply accessibility filter
        if (this.showOnlyAccessible) {
            filtered = filtered.filter(item => item.isAccessible);
        }

        this.filteredData = filtered;
        
        // Reapply sort if active
        if (this.sortedBy) {
            this.sortData(this.sortedBy, this.sortedDirection);
        }
    }

    /** @description Sorts filteredData by the given field and direction; coerces booleans to
     *  integers so they sort correctly alongside text fields. */
    sortData(fieldName, direction) {
        let parseData = [...this.filteredData];
        
        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            let xVal = x[fieldName] !== undefined && x[fieldName] !== null ? x[fieldName] : '';
            let yVal = y[fieldName] !== undefined && y[fieldName] !== null ? y[fieldName] : '';
            
            // Handle boolean comparison
            if (typeof xVal === 'boolean') {
                xVal = xVal ? 1 : 0;
                yVal = yVal ? 1 : 0;
            }
            
            return isReverse * ((xVal > yVal) - (yVal > xVal));
        });

        this.filteredData = parseData;
    }

    get hasData() {
        return this.filteredData && this.filteredData.length > 0;
    }

    get recordCount() {
        return this.filteredData.length;
    }

    get totalRecords() {
        return this.hierarchyData.length;
    }

    get inaccessibleCount() {
        return this.hierarchyData.filter(item => !item.isAccessible).length;
    }

    get showStats() {
        return this.hierarchyData.length > 0;
    }
}