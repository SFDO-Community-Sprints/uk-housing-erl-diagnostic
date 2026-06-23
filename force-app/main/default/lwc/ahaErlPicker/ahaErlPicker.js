import { api, track, LightningElement, wire } from 'lwc';
import generateSeedData from '@salesforce/apex/AhaErlSeedDataController.generateSeedData';
import isEmpty from '@salesforce/apex/AhaErlSeedDataController.isEmpty';
import getSORRootCategories from '@salesforce/apex/AhaErlController.getSORRootCategories';
import AhaErlIcons from '@salesforce/resourceUrl/AhaErlIcons';
import getLocations from '@salesforce/apex/AhaErlController.getLocations';
import getAllProfiles from '@salesforce/apex/AhaErlController.getAllProfiles';
import logTracking from '@salesforce/apex/AhaErlController.logTracking';
import isSandbox from '@salesforce/apex/AhaErlController.isSandbox';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
//import logMyAhaErlJob from '@salesforce/apex/ERLMyAhaErlController.logMyAhaErlJob';
// import findTheRepair from '@salesforce/apex/M3CentralController.findTheRepair';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';

/**
 * @description Root orchestrator component for the Easy Repair Locator — loads repair profiles,
 * root categories, and locations on initialisation and drives the full category navigation and
 * SOR selection flow, supporting both Flow and standalone repairMode contexts.
 */
export default class AhaErlPicker extends NavigationMixin(LightningElement) {
    @api repairProfile = 'Default DIAG';
    @api repairMode;
    @api editMode = false;
    @api varButtonPressed;
    @api outputTextJSON = '';
    @api outputApex;
    @api displayTabs = false;
    //flow only inputs
    @api caseId;
    @api addressText;
    guidedUser = false;
    @api showCreateReferralButton = false;
    @api createReferralButtonLabel = 'Create Referral';
    @api allowSearch = false;
    @api myAhaErlMode = false;

    categories = [];
    @track displayedCategories = [];
    @track selectedCategory;
    @track selectedSORs = [];
    @track repairLocations = [];
    @track isSpinnerOn = false;

    allRepairProfiles = [];
    @track displayedRepairProfiles = [];

    //for edit mode
    @track defaultProfileOptions = ['ALL'];

    isSandbox = false;
    @track showSeedButton = false;
    staticTimeStarted = new Date();
    timeStarted = new Date();
    path = 'START';
    completePath = 'START';
    pickerIsEnding = false;
    buttonClick = false;
    init = true;
    boundPathHandler;
    currentUserName = '';

    @wire(getRecord, { recordId: userId, fields: [USER_NAME_FIELD] })
    wiredCurrentUser({ data }) {
        if (data) {
            this.currentUserName = getFieldValue(data, USER_NAME_FIELD) || '';
        }
    }

    get displayFooter() {
        return !this.myAhaErlMode;
    }

    get getGuidedModeLabel() {
        return this.guidedUser ? 'Guided Mode On' : 'Guided Mode Off';
    }

    get notGuidedUser() {
        return !this.guidedUser;
    }

    get hasAddressText() {
        return this.addressText !== undefined && this.addressText !== null && this.addressText !== '';
    }

    get isEditContext() {
        return this.repairMode === 'EDIT';
    }

    get isFlowContext() {
        return this.repairMode === 'FLOW' || this.repairMode === 'EDIT';
    }

    get showCreateReferralAction() {
        return this.guidedUser && this.showCreateReferralButton;
    }

    get getIsCategoryPicked() {
        return this.selectedCategory !== undefined && this.selectedCategory !== null;
    }

    get getIsCategoryNotPicked() {
        return this.selectedCategory === undefined || this.selectedCategory === null;
    }
    
    get getIsNextDisabled() {
        return this.selectedSORs.length === 0;
    }

    handleEditProfileChange(event) {
        this.defaultProfileOptions = event.detail;
    }

    /**
     * @description Initialises the component by fetching root categories for the current profile,
     * available repair locations, all repair profiles (edit mode only), and the sandbox flag from Apex.
     * In edit context, also checks whether ERL is empty to conditionally show the seed data button.
     */
    connectedCallback() {
        this.isSpinnerOn = true;
        this.boundPathHandler = this.logTrackingEventHandler.bind(this);
        this.template.addEventListener('rivsorselector__path', this.boundPathHandler);
        if (this.isEditContext) {
            this.allowSearch = true;
        }
        getSORRootCategories({profileName: this.repairProfile}).then((data) => {
            data.forEach((category) => {
                category.ImageUrl = AhaErlIcons + '/' + category.imageFileText;
            });
            this.categories = data;
            this.displayedCategories = this.categories.filter((category) => {
                return (category.isGuided === this.guidedUser);
            });
            this.markActiveDisplayedCategories();
            this.isSpinnerOn = false;
        });
        getLocations().then((data) => {
            this.repairLocations = data;
            if (this.outputTextJSON !== '' && !this.guidedUser) {
                let tempSelectedSors = JSON.parse(this.outputTextJSON).repairSorLines;
                this.unOutputText(this.outputTextJSON);
            }
        });
        if (this.isEditContext) {
            getAllProfiles().then((data) => {
                this.allRepairProfiles = [];
                data.forEach((profile) => {
                    let tempProfile = {};
                    tempProfile.label = profile.Name;
                    tempProfile.value = profile.Name;
                    tempProfile.description = profile.Description__c;
                    tempProfile.isGuided = profile.Guided__c;
                    this.allRepairProfiles.push(tempProfile);
                });
                this.displayedRepairProfiles = this.allRepairProfiles.filter((profile) => {
                    return (profile.isGuided === this.guidedUser || profile.label === 'ALL');
                });
                let repairProfileSelector = this.template.querySelector('.repair-profile-selector');
                repairProfileSelector.value = this.repairProfile;
            });
        }
        isSandbox().then((data) => {
            this.isSandbox = data;
        });
        if (this.isEditContext) {
            isEmpty().then((data) => {
                this.showSeedButton = data;
            });
        }
    }

    handleGuidedModeCheckbox() {
        this.guidedUser = !this.guidedUser;
        this.displayedCategories = this.categories.filter((category) => {
            return (category.isGuided === this.guidedUser);
        });
        this.markActiveDisplayedCategories();
        this.displayedRepairProfiles = this.allRepairProfiles.filter((profile) => {
            return (profile.isGuided === this.guidedUser || profile.label === 'ALL');
        });
        this.handleBack();
    }

    handleRepairProfileChange(event) {
        this.repairProfile = event.currentTarget.value;
        this.handleEditedCategory();
    }

    /** @description Calls Apex to generate the example data hierarchy, then reloads categories. */
    handleGenerateSeedData() {
        this.isSpinnerOn = true;
        generateSeedData().then((result) => {
            if (result.startsWith('error')) {
                const toastEvent = new ShowToastEvent({ title: 'Error', message: result, variant: 'error' });
                this.dispatchEvent(toastEvent);
                this.isSpinnerOn = false;
            } else {
                this.showSeedButton = false;
                this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: result, variant: 'success' }));
                this.handleEditedCategory();
            }
        });
    }

    /**
     * @description Refreshes the root category list from Apex after a profile change or
     * an admin edit to a category.
     */
    handleEditedCategory() {
        this.isSpinnerOn = true;
        getSORRootCategories({profileName: this.repairProfile}).then((data) => {
            data.forEach((category) => {
                category.ImageUrl = AhaErlIcons + '/' + category.imageFileText;
            });
            this.categories = data;
            this.displayedCategories = this.categories.filter((category) => {
                return category.isGuided === this.guidedUser;
            });
            this.markActiveDisplayedCategories();
            this.isSpinnerOn = false;
        });
    }

    handleCategoryTabClick(event) {
        if (this.buttonClick) {
            this.buttonClick = false;
            return;
        }
        this.logTrackingEvent(event.currentTarget.dataset.label);
        this.selectedCategory = event.currentTarget.dataset.id;
        this.markActiveDisplayedCategories();
    }

    handleCategoryButtonClick(event) {
        this.buttonClick = true;
        this.logTrackingEvent(event.currentTarget.dataset.label);
        this.selectedCategory = event.currentTarget.dataset.id;
        this.markActiveDisplayedCategories();
    }

    handleGuidedSelectionTabClick(event) {
        this.init = false;
        this.logTrackingEvent('GUIDED SELECTION TAB');
    }

    handleSearchTabClick(event) {
        this.logTrackingEvent('SEARCH TAB');
    }

    handleBack() {
        this.buttonClick = true;
        this.logTrackingEvent('BACK');
        this.selectedCategory = undefined;
        this.markActiveDisplayedCategories();
    }

    /** @description Marks the currently selected category as active in the displayed list
     *  to drive active-state styling in the template. */
    markActiveDisplayedCategories() {
        this.displayedCategories = (this.displayedCategories || []).map((category) => {
            return {
                ...category,
                isActive: this.selectedCategory !== undefined && this.selectedCategory !== null && category.id === this.selectedCategory
            };
        });
    }

    disconnectedCallback() {
        if (this.boundPathHandler) {
            this.template.removeEventListener('rivsorselector__path', this.boundPathHandler);
            this.boundPathHandler = null;
        }
    }

    handleDeleteSor(event) {
        let sorId = event.detail.id;
        for (let i = 0; i < this.selectedSORs.length; i++) {
            if (this.selectedSORs[i].id === sorId) {
                this.selectedSORs.splice(i, 1);
                break;
            }
        }
    }

    handleEditSor(event) {
        let selectedSOR = JSON.parse(JSON.stringify(event.detail));
        for (let i = 0; i < this.selectedSORs.length; i++) {
            if (this.selectedSORs[i].id === selectedSOR.id) {
                this.selectedSORs[i] = selectedSOR;
                break;
            }
        }
    }

    /** @description Adds the selected SOR to the list, rejecting duplicates with a toast. */
    handleSorSelection(event) {
        let selectedSOR = this.buildSelectedSorRecord(JSON.parse(JSON.stringify(event.detail)));
        selectedSOR.jobTitle = selectedSOR.heading;
        for (let i = 0; i < this.selectedSORs.length; i++) {
            if (this.selectedSORs[i].id === selectedSOR.id) {
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'SOR already selected. Please select a different SOR.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                return;
            }
        }
        this.selectedSORs.push(selectedSOR);
        this.logTrackingData(selectedSOR.sorCode);
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'SOR added to job.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }

    /** @description Collects SORs from a guided-mode problem selection, attaches the user's
     *  free-text details to each, and advances the flow. */
    handleGuidedSubmit(event) {
        //for each sor in sorList, add to selectedSORs
        let selectedSORs = event.detail.selectedProblem.sorList;
        selectedSORs.forEach((sor) => {
            this.logTrackingData(sor.sorCode);
            let tempSOR = this.buildSelectedSorRecord(sor, {
                location: sor.location || 'UNK',
                comment: event.detail.guidedModeDetails,
                jobTitle: event.detail.selectedProblem.label
            });
            this.selectedSORs.push(tempSOR);
        });
        this.handleNextButton();
    }

    handleCancelButton() {
        this.varButtonPressed = 'BACK';
        this.pickerIsEnding = true;
        this.logTrackingData('CANCEL');
        this.moveNext();
    }

    handleNextButton() {
        this.varButtonPressed = 'NEXT';
        const timestamp = this.buildOutputTimestamp();
        this.outputApex = this.buildOutputApexObject(timestamp);
        this.outputTextJSON = JSON.stringify(this.buildOutputObject(timestamp));
        this.pickerIsEnding = true;
        this.logTrackingData('NEXT');
        this.moveNext();
    }

    handleUnableToSelect() {
        this.pickerIsEnding = true;
        this.varButtonPressed = 'REFERRAL';
        this.logTrackingData('REFERRAL')
        this.moveNext();
    }

    handlePreviousButton() {
        this.pickerIsEnding = true;
        this.varButtonPressed = 'BACK';
        this.logTrackingData('BACK');
        this.moveNext();
    }

    logTrackingEventHandler(event) {
        this.logTrackingEvent(event.detail);
    }

    logTrackingEvent(pathTaken) {
        this.path += ' -> ' + pathTaken;
        this.completePath += ' -> ' + pathTaken;
    }

    /** @description Builds and fires a tracking record to Apex with elapsed time, navigation
     *  path, and type (PARTIAL vs COMPLETE), then resets the path/timer for the next segment. */
    logTrackingData(item) {
        const iprofile = this.repairProfile;
        let itime;
        const iitem = item;
        let ipath;
        let ttype;
        if (this.pickerIsEnding) {
            itime = Math.round((new Date() - this.staticTimeStarted) / 1000);
            ipath = this.completePath;
            ttype = 'COMPLETE';
        } else {
            itime = Math.round((new Date() - this.timeStarted) / 1000);
            ipath = this.path;
            ttype = 'PARTIAL';
        }
        logTracking({path: ipath, 
                    itime: itime.toString(), 
                    item: iitem, 
                    profile: iprofile,
                    type: this.guidedUser ? 'GUIDED' : 'DIAGNOSTIC',
                    trackerType: ttype
                });
        this.path = 'CONTINUE';
        this.timeStarted = new Date();
    }

    moveNext() {
        const nextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextEvent);
    }

    /** @description Serialises the selected SOR list to the JSON output format expected by
     *  downstream Flow variables and external integrations. */
    outputText() {
        return JSON.stringify(this.buildOutputObject(this.buildOutputTimestamp()));
    }

    buildOutputTimestamp() {
        return new Date().toISOString();
    }

    buildSelectedSorRecord(sor, overrides = {}) {
        return {
            id: sor.id,
            sorCode: sor.sorCode,
            heading: sor.heading,
            fullDescription: sor.fullDescription,
            quantity: sor.quantity,
            priority: sor.priority,
            trade: sor.trade,
            rate: sor.rate,
            location: sor.location,
            comment: sor.comment,
            jobTitle: sor.jobTitle,
            ...overrides
        };
    }

    buildOutputLine(sor) {
        return {
            outputReference: sor.outputReference,
            SOR_Unit: 'NO',
            SOR_Trade: sor.trade,
            SOR_Code: sor.sorCode,
            SOR_Subject: sor.heading,
            SOR_Description: sor.fullDescription,
            SOR_Quantity: sor.quantity !== undefined && sor.quantity !== null ? sor.quantity.toString() : '0',
            SOR_Priority: sor.priority,
            SOR_JobTitle: sor.jobTitle,
            SOR_Heading: sor.heading,
            SOR_Comment: sor.comment,
            SOR_Rate: sor.rate ? sor.rate.toString() : '0',
            repair_location: sor.location
        };
    }

    buildOutputObject(timestamp) {
        return {
            userId,
            userName: this.currentUserName,
            timestamp,
            repairSorLines: (this.selectedSORs || []).map((sor, index) => this.buildOutputLine({
                ...sor,
                outputReference: index + 1
            })),
        };
    }

    buildOutputApexLine(sor) {
        return {
            outputReference: sor.outputReference,
            sorUnit: 'NO',
            sorTrade: sor.trade,
            sorCode: sor.sorCode,
            sorSubject: sor.heading,
            sorDescription: sor.fullDescription,
            sorQuantity: sor.quantity !== undefined && sor.quantity !== null ? sor.quantity.toString() : '0',
            sorPriority: sor.priority,
            sorJobTitle: sor.jobTitle,
            sorHeading: sor.heading,
            sorComment: sor.comment,
            sorRate: sor.rate ? sor.rate.toString() : '0',
            repairLocation: sor.location
        };
    }

    buildOutputApexObject(timestamp) {
        return {
            userId,
            userName: this.currentUserName,
            timestamp,
            repairSorLines: (this.selectedSORs || []).map((sor, index) => this.buildOutputApexLine({
                ...sor,
                outputReference: index + 1
            })),
        };
    }

    /** @description Deserialises a previously serialised JSON output back into the selectedSORs
     *  array, resolving location labels from the loaded locations map. */
    unOutputText(repairslineJSON) {
        let repairsline = JSON.parse(repairslineJSON);
        repairsline.repairSorLines.forEach((sor) => {
            let tempSOR = {};
            tempSOR.id = sor.id;
            tempSOR.sorCode = sor.SOR_Code;
            tempSOR.heading = sor.SOR_Subject;
            tempSOR.fullDescription = sor.SOR_Description;
            tempSOR.quantity = sor.SOR_Quantity;
            tempSOR.priority = sor.SOR_Priority;
            tempSOR.heading = sor.SOR_JobTitle;
            tempSOR.trade = sor.SOR_Trade;
            tempSOR.rate = sor.SOR_Rate ? sor.SOR_Rate : '0';
            tempSOR.comment = sor.SOR_Comment;
            tempSOR.location = sor.repair_location;

            let locationLabel = '';
            for (let key in this.repairLocations) {
                if (this.repairLocations[key] === tempSOR.location) {
                    locationLabel = key;
                    break;
                }
            }
            tempSOR.locationLabel = locationLabel;

            this.selectedSORs.push(tempSOR);
        });
    }

    handleEditModeCheckbox() {
        this.editMode = !this.editMode;
    }
    handleEditSor(event) {
        let selectedSOR = JSON.parse(JSON.stringify(event.detail));
        for (let i = 0; i < this.selectedSORs.length; i++) {
            if (this.selectedSORs[i].id === selectedSOR.id) {
                this.selectedSORs[i] = selectedSOR;
                break;
            }
        }
    }

    handleSpinnerOn() {
        this.isSpinnerOn = true;
    }

    handleSpinnerOff() {
        this.isSpinnerOn = false;
    }
}