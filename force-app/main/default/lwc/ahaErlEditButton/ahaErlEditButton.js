import { LightningElement, api, track } from 'lwc';
import addExistingMessageToCategory from '@salesforce/apex/AhaErlController.addExistingMessageToCategory';
import addMessagetoCategory from '@salesforce/apex/AhaErlController.addMessagetoCategory';
import addNewCategory from '@salesforce/apex/AhaErlController.addCategory';
import addSORtoCategory from '@salesforce/apex/AhaErlController.addSORtoCategory';
import assignProfilestoSOR from '@salesforce/apex/AhaErlController.assignProfilestoSOR';
import deleteCategory from '@salesforce/apex/AhaErlController.deleteCategory';
import editCategory from '@salesforce/apex/AhaErlController.editCategory';
import editMessage from '@salesforce/apex/AhaErlController.editMessage';
import saveCategoryGuidance from '@salesforce/apex/AhaErlController.saveCategoryGuidance';
import getCurrentJunctionedProfiles from '@salesforce/apex/AhaErlController.getCurrentJunctionedProfiles';
import getAllAvailableMessages from '@salesforce/apex/AhaErlController.getAllAvailableMessages';
import getSORProfileAssignments from '@salesforce/apex/AhaErlController.getSORProfileAssignments';
import removeMessageFromCategory from '@salesforce/apex/AhaErlController.removeMessageFromCategory';
import AhaErlIcons from '@salesforce/resourceUrl/AhaErlIcons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @description Full-featured admin edit panel for creating, editing, and deleting categories,
 * SOR codes, messages, and item lists, including profile assignment management.
 */
export default class AhaErlEditButton extends LightningElement {
    @api category;
    @api allRepairProfiles;
    @api guidedUser;
    @api newMode = false;
    @api closeup = false;
    @api button = false;
    @api sor = false;
    @api sorSearchEdit = false;
    @api searchsor;
    @api problem = false;
    @api itemlist = false;
    @api message = false;
    @api guidance = false;
    @api repairProfile;
    @api parentCategory;
    @api editTextOverride;
    @track editMode = false;
    @track isDeleting = false;

    updatedParentId;
    updatedCategoryLabel;
    updatedCategoryEditModeLabel;
    updatedCategoryImageFileText;
    updatedMessage;
    updatedGuidanceText;
    updatedIsGuided;
    @track chosenSOR = {};

    allAvailableMessages = [];
    existingMessageChosen = false;
    existingMessageId;

    @api defaultProfileOptions = ['ALL'];
    selectedProfileOptions = ['ALL'];
    profileResultsReceived = false;

    get getIsButtonNotNew() {
        if (this.button && !this.newMode) {
            return true;
        }
        return false;
    }

    get getImageFileNotNeeded() {
        if (this.button || this.itemlist || this.problem || this.message) {
            return true;
        }
        return false;
    }

    get getNewButtonClass() {
        if (this.button) {
            return 'sor-button';
        }
        return 'sor-button';
    }

    get getEditLabel() {
        if (this.editTextOverride) {
            return this.editTextOverride;
        }
        return 'Edit';
    }

    get getNewStyle() {
        if (this.sor) {
            return 'position:absolute;left: 0;top:-130px;width:min(92vw, 760px);max-width:92vw;';
        } else if (this.guidance) {
            return 'position:absolute;left: 0;top:-90%;width:min(92vw, 840px);max-width:92vw;';
        } else {
            return 'position:absolute;left: 0;top:-90%;width:min(92vw, 640px);max-width:92vw;';
        }
    }

    get getSORSearchPopoverStyle() {
        return 'width:min(92vw, 500px);max-width:92vw;';
    }

    get getEditStyle() {
        if (this.button || this.sorSearchEdit) {
            return 'position:relative;width:150px;'
        } else {
            return 'position:relative;width:100%;'
        }
    }

    get buttonOrSearchSOR() {
        return this.sorSearchEdit || this.button;
    }

    get addCategoryIcon() { 
        if (this.closeup) {
            return AhaErlIcons + '/ADDIMAGE.jpg';
        } else if (this.itemlist) {
            return AhaErlIcons + '/ADDITEMLIST.jpg';
        } else if (this.problem) {
            return AhaErlIcons + '/ADDPROBLEM.jpg';
        } else if (this.message) {
            return AhaErlIcons + '/ADDMESSAGE.jpg';
        }
        return AhaErlIcons + '/PLUS.jpg';
    }

    get getClass() {
        if (this.editMode) {
            return 'slds-popover slds-show slds-transition-show riv-sor-popover';
        }
        return 'slds-popover slds-hide slds-transition-hide riv-sor-popover';
    }

    get getAddLabel() {
        if (this.closeup) { 
            return 'Add Closeup'; 
        } else if (this.button) {
            return 'Add Button';
        } else if (this.itemlist) {
            return 'Add Item List';
        } else if (this.sor) {
            return 'Add SOR';
        } else if (this.problem) {
            return 'Add Problem';
        } else if (this.message) {
            return 'Add Message';
        }
        return 'Add Category';
    }

    get getRecordTypeName() {
        if (this.closeup) {
            return 'RepairLocationCloseup';
        } else if (this.button) {
            return 'RepairLocationButton';
        } else if (this.itemlist || this.problem) {
            return 'ItemList';
        } else if (this.message) {
            return 'Message';
        }
        return 'RepairCategory';
    }

    get getNewLabelPopoverText() {
        if (this.closeup) {
            return 'NEW CLOSEUP';
        } else if (this.button) {
            return 'NEW BUTTON';
        } else if (this.itemlist) {
            return 'NEW ITEMLIST';
        } else if (this.sor) {
            return 'NEW SOR';
        } else if (this.problem) {
            return 'NEW PROBLEM';
        } else if (this.message) {
            return 'NEW MESSAGE';
        }
        return 'NEW CATEGORY';
    }

    get getNewCategoryNameLabel() {
        if (this.closeup) {
            return 'New Closeup Name';
        } else if (this.button) {
            return 'New Button Name';
        } else if (this.itemlist) {
            return 'New Item List Name';
        } else if (this.sor) {
            return 'New SOR Name';
        } else if (this.problem) {
            return 'New Problem Name';
        } else if (this.message) {
            return 'API Name';
        }
        return 'New Category Name';
    }

    get getEditCategoryNameLabel() {
        if (this.message) {
            return 'API Name';
        }
        return 'Change name';
    }

    get categoryNameMaxLength() {
        return this.message ? 10 : null;
    }

    get getNewCategoryImageLabel() {
        if (this.closeup) {
            return 'New Closeup Image (uses AhaErlImages)';
        }
        return 'New Category Image (uses AhaErlIcons)';    
    }

    get getEditCategoryImageLabel() {
        if (this.closeup) {
            return 'Edit Closeup Image (usesAhaErlImages)';
        }
        return 'Edit Category Image (uses AhaErlIcons)';
    }

    get getEditIcon() {
        if (this.editMode) {
            return 'utility:close';
        } else {
            return 'utility:edit';
        }
    }

    get getAllAvailableMessagesForCombobox() {
        return this.allAvailableMessages.map((msg, index) => {
            return { label: msg.SORCodeText__c, value: index, description: msg.Message__c };
        });
    }

    connectedCallback() {
        if (this.newMode) {
            if (this.defaultProfileOptions !== this.selectedProfileOptions) {
                this.selectedProfileOptions = this.defaultProfileOptions;
            }
        }
        if (this.category) {
            this.updatedMessage = this.category.message;
            this.updatedCategoryLabel = this.category.label;
            this.updatedCategoryImageFileText = this.category.imageFileText;
            this.updatedGuidanceText = this.category.guidance;
        } else {
            this.updatedCategoryLabel = '';
            this.updatedCategoryImageFileText = '';
            this.updatedGuidanceText = '';
        }
        if (this.parentCategory) {
            this.updatedParentId = this.parentCategory;
        }
    }

    /**
     * @description Fetches the current profile assignments for the SOR being edited from Apex
     * the first time the edit popover is rendered in search-edit mode.
     */
    renderedCallback() {
        if (this.sorSearchEdit && this.editMode && !this.profileResultsReceived) {
            console.log('searching for: ' + this.searchsor);
            getSORProfileAssignments({ sor: this.searchsor })
                .then(result => {
                    console.log('get sor profiles: ' + result);
                    if (result && result.length > 0) {
                        this.defaultProfileOptions = result;
                        this.selectedProfileOptions = result;
                    } else {
                        this.defaultProfileOptions = [];
                    }
                    this.profileResultsReceived = true;
                });
        }
    }

    handleProfileTabSelect() {
        
    }

    handleProfileLBChange(event) {
        this.selectedProfileOptions = event.detail.value;
        this.dispatchEvent(new CustomEvent('rivsorselector__editprofilechange', {detail: this.selectedProfileOptions, bubbles: true, composed: true}));
    }

    handleMessageChange(event) {
        this.updatedMessage = event.currentTarget.value;
    }

    handleGuidanceChange(event) {
        this.updatedGuidanceText = event.currentTarget.value;
    }

    handleExistingMessageChoice(event) {
        const selectedMessage = this.allAvailableMessages[event.detail.value];
        this.updatedMessage = selectedMessage.Message__c;
        this.existingMessageId = selectedMessage.Id;
        this.updatedCategoryLabel = '';
        this.updatedCategoryEditModeLabel = '';
        this.updatedCategoryImageFileText = '';
        this.existingMessageChosen = true;
    }

    handleSORPicked(event) {
        
        this.chosenSOR = event.detail;
    }

    handleCategoryNameBlur(event) {
        const labelValue = event.detail && event.detail.value !== undefined ? event.detail.value : event.currentTarget.value;
        this.updatedCategoryLabel = this.message && labelValue ? labelValue.substring(0, 10) : labelValue;
        if (this.updatedCategoryEditModeLabel === undefined || this.updatedCategoryEditModeLabel === null || this.updatedCategoryEditModeLabel === '') {
            this.updatedCategoryEditModeLabel = this.updatedCategoryLabel;
        }
    }

    handleCategoryEditNameChange(event) {
        this.updatedCategoryEditModeLabel = event.detail && event.detail.value !== undefined ? event.detail.value : event.currentTarget.value;
    }

    handleCategoryImageUrlChange(event) {
        this.updatedCategoryImageFileText = event.detail && event.detail.value !== undefined ? event.detail.value : event.currentTarget.value;
    }

    /** @description Routes the save action to editSORProfiles, editMessage, or editCategory
     *  based on the component's current edit context flags. */
    handleEditSave() {
        this.dispatchEvent(new CustomEvent('spinneron'));
        if (this.sorSearchEdit) {
            this.editSORProfiles();
        } else if (this.guidance) {
            const currentGuidance = this.category && this.category.guidance ? this.category.guidance : '';
            const updatedGuidance = this.updatedGuidanceText ? this.updatedGuidanceText : '';
            if (updatedGuidance === currentGuidance) {
                this.editMode = false;
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'No changes to save', variant: 'warning' }));
                this.dispatchEvent(new CustomEvent('spinneroff'));
                return;
            }
            this.editGuidance();
        } else {
            if (this.updatedCategoryLabel === this.category.label 
                && this.updatedCategoryImageFileText === this.category.imageFileText 
                && this.updatedMessage === this.category.message 
                && this.selectedProfileOptions === this.defaultProfileOptions 
                && this.updatedIsGuided === this.category.isGuided
                && this.updatedCategoryEditModeLabel === this.category.editModeLabel) 
            {
                this.editMode = false;
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'No changes to save', variant: 'warning' }));
                return;
            } else {
                if (this.message) {
                    this.editMessage();
                } else {
                    this.editCategory();
                }
            }
        }
    }

    /**
     * @description Saves the updated profile assignments for a SOR code to Salesforce via Apex.
     */
    editSORProfiles() {
        assignProfilestoSOR({ sorCode: this.searchsor, profiles: this.selectedProfileOptions})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.editMode = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
                this.profileResultsReceived = false;
            }
            ).catch(error => {
                
            });
    }

    /**
     * @description Saves rich-text guidance for the current closeup category and active profile.
     */
    editGuidance() {
        saveCategoryGuidance({
            categoryId: this.category.id,
            profileName: this.repairProfile,
            guidanceText: this.updatedGuidanceText
        })
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.editMode = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                const message = (error && error.body && error.body.message) || error.message || 'Unknown error while saving guidance.';
                console.error('Error saving guidance:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
                this.dispatchEvent(new CustomEvent('spinneroff'));
            });
    }

    /**
     * @description Saves edits to a message-type SOR record and its profile assignments via Apex.
     */
    editMessage() {
        editMessage({ recid : this.category.id, message: this.updatedMessage, profiles: this.selectedProfileOptions})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.editMode = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                const message = (error && error.body && error.body.message) || error.message || 'Unknown error while adding category.';
                console.error('Error adding category:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
                this.dispatchEvent(new CustomEvent('spinneroff'));
            });
    }

    /**
     * @description Saves edits to the label, image, guided flag, and profile assignments of the
     * current category record via Apex.
     */
    editCategory() {
        if (this.updatedIsGuided === undefined) {
            if (this.category.isGuided !== undefined && this.category.isGuided) {
                this.updatedIsGuided = true;
            } else {
                this.updatedIsGuided = false;
            }
        }
        editCategory({ details: {'recid': this.category.id,
                                'label': this.updatedCategoryLabel,
                                'editModeLabel': this.updatedCategoryEditModeLabel,
                                'imageFileText': this.updatedCategoryImageFileText,
                                'recordTypeDevName': this.getRecordTypeName,
                                'isGuided': (this.updatedIsGuided ? 'true' : 'false')}, 
                       profiles: this.selectedProfileOptions})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.editMode = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                
            });
    }

    handleNewSave() {
        this.dispatchEvent(new CustomEvent('spinneron'));
        if (this.sor) {
            this.addNewSOR();
        } else if (this.message) {
            this.addNewMessage();
        }else {
            this.addNewCategory();
        }
    }

    /**
     * @description Creates a new message junction or links an existing message to the category
     * via Apex, depending on whether the user selected an existing message.
     */
    addNewMessage() {
        if (this.existingMessageChosen) {
            addExistingMessageToCategory({categoryId : this.category.id, msgId: this.existingMessageId, profiles: this.selectedProfileOptions})
                .then(result => {
                    let toastmsg = result;
                    let toast;
                    if (result.includes('error') || result.includes('you do not have permission')) {
                        toast = new ShowToastEvent({
                            title: 'Error',
                            message: toastmsg,
                            variant: 'error'
                        });
                    } else {
                        toast = new ShowToastEvent({
                            title: 'Success',
                            message: toastmsg,
                            variant: 'success'
                        });
                    }
                    this.dispatchEvent(toast);
                    this.dispatchEvent(new CustomEvent('categoryedited'));
                    this.editMode = false;
                    this.dispatchEvent(new CustomEvent('spinneroff'));
                }
                ).catch(error => {
                    
                });
        } else {
            addMessagetoCategory({categoryId : this.category.id, msgName: this.updatedCategoryLabel, message: this.updatedMessage, profiles: this.selectedProfileOptions})
                .then(result => {
                    let toastmsg = result;
                    let toast;
                    if (result.includes('error') || result.includes('you do not have permission')) {
                        toast = new ShowToastEvent({
                            title: 'Error',
                            message: toastmsg,
                            variant: 'error'
                        });
                    } else {
                        toast = new ShowToastEvent({
                            title: 'Success',
                            message: toastmsg,
                            variant: 'success'
                        });
                    }
                    this.dispatchEvent(toast);
                    this.dispatchEvent(new CustomEvent('categoryedited'));
                    this.editMode = false;
                    this.dispatchEvent(new CustomEvent('spinneroff'));
                }
                ).catch(error => {
                    
                });
        }
    }

    /**
     * @description Links the chosen SOR code to the current category via Apex.
     */
    addNewSOR() {
        if (!this.chosenSOR || !this.chosenSOR.id) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a SOR code first',
                variant: 'error'
            }));
            this.dispatchEvent(new CustomEvent('spinneroff'));
            return;
        }
        
        addSORtoCategory({categoryId : this.category.id, sor: this.chosenSOR.id})
            .then(result => {
                this.editMode = false;
                
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                
            });
    }

    /**
     * @description Creates a new child category under the current parent with the provided
     * label, image, record type, and profile assignments via Apex.
     */
    addNewCategory() {
        if (this.updatedIsGuided === undefined) {
            if (this.guidedUser) {
                this.updatedIsGuided = true;
            } else {
                this.updatedIsGuided = false;
            }
        }
        addNewCategory({ details: {
                            'parentId': this.updatedParentId,
                            'label': this.updatedCategoryLabel,
                            'editModeLabel': this.updatedCategoryEditModeLabel,
                            'imageFileText': this.updatedCategoryImageFileText,
                            'recordTypeDevName': this.getRecordTypeName,
                            'isGuided': (this.updatedIsGuided ? 'true' : 'false')
                        },
                        profiles: this.selectedProfileOptions})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.editMode = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                
            });
    }

    handleDeleteConfirmed() {
        this.dispatchEvent(new CustomEvent('spinneron'));
        if (this.message) {
            this.deleteMessageFromCategory();
        } else {
            this.deleteCategory();
        }
    }

    /**
     * @description Removes the message junction record from the category via Apex.
     */
    deleteMessageFromCategory() {
        removeMessageFromCategory({ recid: this.category.id , categoryId : this.parentCategory})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.isDeleting = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                
            });
    }

    /**
     * @description Deletes the current category record and its child relationships via Apex.
     */
    deleteCategory() {
        deleteCategory({ recid : this.category.id})
            .then(result => {
                let toastmsg = result;
                let toast;
                if (result.includes('error') || result.includes('you do not have permission')) {
                    toast = new ShowToastEvent({
                        title: 'Error',
                        message: toastmsg,
                        variant: 'error'
                    });
                } else {
                    toast = new ShowToastEvent({
                        title: 'Success',
                        message: toastmsg,
                        variant: 'success'
                    });
                }
                this.dispatchEvent(toast);
                this.dispatchEvent(new CustomEvent('categoryedited'));
                this.isDeleting = false;
                this.dispatchEvent(new CustomEvent('spinneroff'));
            }
            ).catch(error => {
                
            });
    }

    handleIsGuidedChange(event) {
        this.updatedIsGuided = event.currentTarget.checked;
    }

    /**
     * @description Opens the edit popover; fetches all available messages from Apex when editing
     * a message node, and fetches current profile junctions from Apex when editing an existing category or SOR.
     */
    handleEdit() {
        if (this.message) {
            this.existingMessageChosen = false;
            this.existingMessageId = null;
            getAllAvailableMessages()
                .then(result => {
                    if (result && result.length > 0) {
                        this.allAvailableMessages = result;
                    }
                });
        }
        if (this.guidance) {
            this.updatedGuidanceText = this.category && this.category.guidance ? this.category.guidance : '';
        }
        if (this.category) {
            if (this.category.id && !this.newMode && !this.guidance) {
                getCurrentJunctionedProfiles({categoryId: this.category.id, 
                                            isSor: this.sor || this.message})
                .then(result => {
                    if (result && result.length > 0) {
                        this.defaultProfileOptions = result;
                        this.selectedProfileOptions = result;
                    } else {
                        this.defaultProfileOptions = [];
                    }
                });
            }
        }
        this.editMode = !this.editMode;
    }

    handleEditCancel() {
        this.editMode = false;
    }

    handleEditDelete() {
        this.isDeleting = true;
    }

    handleDeleteCancel() {
        this.isDeleting = false;
    }

}