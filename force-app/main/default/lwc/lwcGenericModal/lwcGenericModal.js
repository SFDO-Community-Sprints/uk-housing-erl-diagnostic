import { api } from 'lwc';
import LightningModal from 'lightning/modal';

/**
 * @description Reusable modal dialog supporting OK/Cancel actions, an optional combobox with
 * "Other" free-text fallback, case comment display, and embedded Flow execution.
 */
export default class LwcGenericModal extends LightningModal {
    @api header;
    @api content;
    @api CaseComment;
    @api displayOkButton;
    @api okButton = {};
    @api displayCancelButton;
    @api cancelButton = {};
    @api combobox = {};

    //when flow is supplied, the modal closes when the flow is finished.
    @api flowName;
    @api flowParams;

    selectedComboboxValue = '';
    otherDetailsValue = '';

    get onlyDisplayingCloseButton() {
        return !this.displayOkButton && !this.displayCancelButton && !this.isFlow;
    }

    get okButtonVariant() {
        return this.okButton.variant || 'brand';
    }

    get okButtonLabel() {
        return this.okButton.label || 'OK';
    }

    get cancelButtonVariant() {
        return this.cancelButton.variant || 'neutral';
    }

    get cancelButtonLabel() {
        return this.cancelButton.label || 'Cancel';
    }

    get isFlow() {
        return !!this.flowName;
    }

    get hasContent() {
        return !!this.content;
    }

    get isCaseComment() {
        return !!this.CaseComment;
    }

    get hasCombobox() {
        return !!this.combobox && !!this.combobox.options;
    }

    /** @description Returns the configured combobox options, automatically appending an
     *  "Other" entry when allowOther is true and it is not already present. */
    get comboboxOptions() {
        let options = this.combobox.options || [];
        
        // Automatically add "Other" as the last option if allowOther is true
        if (this.allowOther) {
            const hasOther = options.some(option => option.value === 'Other');
            if (!hasOther) {
                options = [...options, { label: 'Other', value: 'Other' }];
            }
        }
        
        return options;
    }

    get comboboxLabel() {
        return this.combobox.label || 'Select an option';
    }

    get comboboxPlaceholder() {
        return this.combobox.placeholder || 'Choose an option...';
    }

    get isComboboxRequired() {
        return this.combobox.required || false;
    }

    get allowOther() {
        return this.combobox.allowOther || false;
    }

    get isOtherSelected() {
        return this.allowOther && this.selectedComboboxValue === 'Other';
    }

    get otherDetailsLabel() {
        return this.combobox.otherDetailsLabel || 'Other Details';
    }

    get otherDetailsPlaceholder() {
        return this.combobox.otherDetailsPlaceholder || 'Please specify...';
    }

    get isOkButtonDisabled() {
        if (this.hasCombobox && this.isComboboxRequired) {
            if (!this.selectedComboboxValue) {
                return true;
            }
            if (this.isOtherSelected && !this.otherDetailsValue.trim()) {
                return true;
            }
        }
        return false;
    }

    /** @description Returns the free-text "Other" input when that option is selected,
     *  otherwise returns the selected combobox value. */
    get finalComboboxValue() {
        if (this.isOtherSelected) {
            return this.otherDetailsValue.trim();
        }
        return this.selectedComboboxValue;
    }

    handleComboboxChange(event) {
        this.selectedComboboxValue = event.detail.value;
        if (this.selectedComboboxValue !== 'Other') {
            this.otherDetailsValue = '';
        }
    }

    handleOtherDetailsChange(event) {
        this.otherDetailsValue = 'Other: ' + event.detail.value;
    }

    handleClose() {
        this.close(undefined);
    }

    handleOk() {
        if (this.hasCombobox) {
            this.close({
                confirmed: true,
                comboboxValue: this.finalComboboxValue
            });
        } else {
            this.close(true);
        }
    }

    handleCancel() {
        this.close(false);
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.close(true);
        }
    }
}