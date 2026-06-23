import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cloneProfile from '@salesforce/apex/AhaErlController.cloneProfile';
import deleteProfile from '@salesforce/apex/AhaErlController.deleteProfile';
import getAllProfiles from '@salesforce/apex/AhaErlController.getAllProfiles';

/**
 * @description Admin interface for managing repair profiles — lists all profiles in a data table
 * and provides clone and delete operations.
 */
export default class AhaErlProfiles extends LightningElement {
    @api allRepairProfiles;
    @api defaultProfileOptions;

    repairProfileColumns = [
        { label: 'Profile Name', fieldName: 'label', type: 'text' },
        { label: 'Profile Description', fieldName: 'description', type: 'text' },
        { type: 'action', typeAttributes: { rowActions: [{ label: 'Clone', name: 'clone' },
                                                         { label: 'Delete', name: 'delete' },
                                                         { label: 'View All Assigned SORs', name: 'viewAllSors' }] } }
    ];
    @track cloningProfile = false;
    @track confirmProfileDelete = false;
    @track viewAllSors = false;
    @track isCloningInProgress = false;
    @track isDeletingInProgress = false;
    newProfileName;
    newProfileDesc;
    selectedProfileToCloneOrDelete;

    get disableCloneActions() {
        return this.isCloningInProgress;
    }

    get disableDeleteActions() {
        return this.isDeletingInProgress;
    }
    
    handleProfileRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedProfileToCloneOrDelete = row.value;
        switch (actionName) {
            case 'clone':
                this.cloningProfile = true;
                break;
            case 'delete':
                this.confirmProfileDelete = true;
                break;
            case 'viewAllSors':
                this.viewAllSors = true;
                break;
            default:
        }
    }

    handleNewProfileNameChange(event) {
        this.newProfileName = event.currentTarget.value;
    }

    handleNewProfileDescChange(event) {
        this.newProfileDesc = event.currentTarget.value;
    }

    /**
     * @description Clones the selected profile under a new name via Apex, then refreshes
     * the profiles list.
     */
    handleSaveCloneProfile() {
        if (this.isCloningInProgress) {
            return;
        }
        if (!this.newProfileName || this.newProfileName.trim() === '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter a name for the new profile.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        if (!this.newProfileDesc || this.newProfileDesc.trim() === '') {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter a description for the new profile.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        this.isCloningInProgress = true;
        cloneProfile({newName: this.newProfileName, newDesc: this.newProfileDesc, profileName: this.selectedProfileToCloneOrDelete}).then((data) => {
            let toast;
            if (data.includes('error')) {
                toast = new ShowToastEvent({
                    title: 'Error',
                    message: data,
                    variant: 'error'
                });
            } else {
                toast = new ShowToastEvent({
                    title: 'Success',
                    message: 'Profile cloned successfully.',
                    variant: 'success'
                });
            }
            this.dispatchEvent(toast);
            this.cloningProfile = false;
            this.repairProfile = this.newProfileName;
            this.newProfileName = '';
            this.newProfileDesc = '';
            getAllProfiles().then((data) => {
                this.allRepairProfiles = [];
                data.forEach((profile) => {
                    let tempProfile = {};
                    tempProfile.label = profile.Name;
                    tempProfile.value = profile.Name;
                    this.allRepairProfiles.push(tempProfile);
                    this.cloningProfile = false;
                });
            });
        }).catch((error) => {
            console.error('Error cloning profile:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Error cloning profile.',
                variant: 'error'
            }));
        }).finally(() => {
            this.isCloningInProgress = false;
        });
    }

    /**
     * @description Deletes the selected profile via Apex, then refreshes the profiles list.
     */
    handleDeleteProfile() {
        if (this.isDeletingInProgress) {
            return;
        }
        this.isDeletingInProgress = true;
        deleteProfile({profileName: this.selectedProfileToCloneOrDelete}).then((data) => {
            let toast;
            if (data.includes('error')) {
                toast = new ShowToastEvent({
                    title: 'Error',
                    message: data,
                    variant: 'error'
                });
            } else {
                toast = new ShowToastEvent({
                    title: 'Success',
                    message: 'Profile deleted successfully.',
                    variant: 'success'
                });
            }
            this.dispatchEvent(toast);
            this.confirmProfileDelete = false;
            getAllProfiles().then((data) => {
                this.allRepairProfiles = [];
                data.forEach((profile) => {
                    let tempProfile = {};
                    tempProfile.label = profile.Name;
                    tempProfile.value = profile.Name;
                    this.allRepairProfiles.push(tempProfile);
                    this.confirmProfileDelete = false;
                });
            });
        }).catch((error) => {
            console.error('Error deleting profile:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Error deleting profile.',
                variant: 'error'
            }));
        }).finally(() => {
            this.isDeletingInProgress = false;
        });
    }

    handleCancelDeleteProfile() {
        if (this.isDeletingInProgress) {
            return;
        }
        this.confirmProfileDelete = false;
    }

    handleCancelCloneProfile() {
        if (this.isCloningInProgress) {
            return;
        }
        this.cloningProfile = false;
    }

    handleBackToProfiles() {
        this.viewAllSors = false;
    }
}