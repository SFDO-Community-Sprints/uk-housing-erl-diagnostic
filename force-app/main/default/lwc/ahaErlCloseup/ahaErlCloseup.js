import { LightningElement, api, track } from 'lwc';
import AhaErlImages from '@salesforce/resourceUrl/AhaErlImages';

/**
 * @description Displays the interactive closeup image for a repair location with overlaid, positioned
 * category buttons; includes a mouse-tracking cat animation easter egg on the exterior closeup.
 */
export default class AhaErlCloseup extends LightningElement {

    @api repairProfile;
    @api guidedUser;
    @api allRepairProfiles;
    @api category;
    @api editMode;
    @api repairLocations;
    @api image;
    @api myAhaErlMode;
    @track copiedButtons;

    _buttons = [];

    @api
    get buttons() {
        return this._buttons;
    }

    set buttons(value) {
        this._buttons = value || [];
        this.syncCopiedButtons();
    }

    @track overrideLocation;
    @track selectedItem = '';
    @track isGreyedOut = false;

    moveMode = false;
    tempx;
    tempy;
    tempChange = false;
    @track updateParams = {};
    @track isCatVisible = false;

    @track localSpinner = true;

    @api defaultProfileOptions;
    
    get getIsItemSelected() {
        return this.selectedItem !== undefined && this.selectedItem !== null && this.selectedItem !== '';
    }

    get imgNotLoaded() {
        return this.localSpinner;
    }

    get greyOutClass() {
        return this.isGreyedOut ? 'greyed-out' : 'transition-opacity';
    }

    /** @description Deep-clones the buttons array so child components receive a new reference
     *  and re-render when disabled state changes. */
    syncCopiedButtons() {
        this.copiedButtons = JSON.parse(JSON.stringify(this._buttons));
    }

    connectedCallback() {
        this.syncCopiedButtons();
        if (this.category && !this.myAhaErlMode && this.image.includes('EXTERIOR_CLOSEUP.jpg')) {
            this.isCatVisible = true;
        } else {
            this.isCatVisible = false;
        }
    }

    handleImgLoaded() {
        this.localSpinner = false;
    }

    handleMoveMode(event) { 
        if (event.detail === true) {
            this.moveMode = true;
        } else {
            this.moveMode = false;
        }
    }

    /** @description Converts a mouse-click position to percentage coordinates relative to the
     *  image, clamping to the 5–95% range to keep buttons within visible bounds. */
    getCoords(event) {
        if (!this.editMode || !this.moveMode) {
            return;
        }
        let rect = event.target.getBoundingClientRect();
        let x = event.clientX - rect.left;
        let y = event.clientY - rect.top;
        let xPercent = (x / rect.width) * 100;
        let yPercent = (y / rect.height) * 100;
        xPercent = Math.round(xPercent * 10) / 10;
        yPercent = Math.round(yPercent * 10) / 10;
        this.tempx = xPercent + '%';
        this.tempy = yPercent + '%';
        //ignore if xPercent or yPercent is less than 5 or greater than 95
        if (xPercent < 5 || xPercent > 95 || yPercent < 5 || yPercent > 95) {
            this.tempx = '';
            this.tempy = '';
        } else {
            this.tempChange = true;
            this.updateParams = {x: this.tempx, y: this.tempy};
        }
    }

    handleEditedCategory() {
        this.dispatchEvent(new CustomEvent('categoryedited'));
    }

    /** @description Handles button selection — redirects to another category if a redirect
     *  is set, otherwise dims the closeup and opens the item picker for the selected button. */
    handleItemSelected(event) {
        if (event.detail.redirectToCategory && event.detail.redirectToCategory !== '') {
            this.dispatchEvent(new CustomEvent('rivsorselector__redirectcategory', { detail: event.detail.redirectToCategory , bubbles: true, composed: true }));
            return;
        }
        this.isGreyedOut = true;
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: event.detail.label , bubbles: true, composed: true }));
        this.copiedButtons.forEach(button => {
            button.disabled = true;
        });
        this.selectedItem = event.detail.id;
    }

    handleItemPickerClose() {
        this.isGreyedOut = false;
        this.dispatchEvent(new CustomEvent('rivsorselector__path', { detail: 'BACK' , bubbles: true, composed: true }));
        this.copiedButtons.forEach(button => {
            button.disabled = false;
        });
        this.selectedItem = '';
    }

    handleLocationChange (event) {
        this.overrideLocation = event.detail;
    }

    showSpinner() {
        this.dispatchEvent(new CustomEvent('spinneron'));
    }

    hideSpinner() {
        this.dispatchEvent(new CustomEvent('spinneroff'));
    }

    get getCat() {
        return AhaErlImages + '/cat.png';
    }

    /** @description Tracks the mouse position and rotates both cat pupils to face the cursor
     *  using atan2, bounded to a quarter of the eye container's radius. */
    handleMouseMove(event) {
        if (!this.isCatVisible || this.localSpinner) {
            return;
        }
        const cat = this.template.querySelector('.cat');
        if (!cat) {
            return;
        }
        const catRect = cat.getBoundingClientRect();
        const eyeLeft = this.template.querySelector('.eye-left .pupil');
        const eyeRight = this.template.querySelector('.eye-right .pupil');
        
        const mouseX = event.clientX;
        const mouseY = event.clientY;

        const updateEyePosition = (eye, eyeContainer) => {
            const eyeContainerRect = eyeContainer.getBoundingClientRect();
            const eyeX = eyeContainerRect.left + eyeContainerRect.width / 2;
            const eyeY = eyeContainerRect.top + eyeContainerRect.height / 2;

            const angle = Math.atan2(mouseY - eyeY, mouseX - eyeX);
            const distance = Math.min(eyeContainerRect.width / 4, eyeContainerRect.height / 4);

            const pupilX = Math.cos(angle) * distance;
            const pupilY = Math.sin(angle) * distance;

            eye.style.transform = `translate(${pupilX}px, ${pupilY}px)`;
        };

        updateEyePosition(eyeLeft, this.template.querySelector('.eye-left'));
        updateEyePosition(eyeRight, this.template.querySelector('.eye-right'));
    }

    removeCat() {
        const cat = this.template.querySelector('.cat');
        cat.classList.add('poof');
        setTimeout(() => {
            this.isCatVisible = false;
        }, 500);
    }

}