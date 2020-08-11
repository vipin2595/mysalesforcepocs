/* eslint-disable no-undef */
/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getActiveChangeRequests from '@salesforce/apex/FLNASCH_PGTMChangeRequestController.getActiveChangeRequests';
import createPgtmChangeRequest from '@salesforce/apex/FLNASCH_PGTMChangeRequestController.createPGTMChangeRequest';
import submitForProcessing from '@salesforce/apex/FLNASCH_PGTMChangeRequestController.submitForProcessing';
import deleteChangeRequests from '@salesforce/apex/FLNASCH_PGTMChangeRequestController.deleteChangeRequests';
import timeZone from '@salesforce/i18n/timeZone'; 
import locale from '@salesforce/i18n/locale';
import saveLabel from '@salesforce/label/c.FLNAAFH_Label_Save';
import cancelLabel from '@salesforce/label/c.FLNAAFH_Label_Cancel';
import errorLabel from '@salesforce/label/c.FLNASCH_error';
import pgtmAcknowledgementMessage from '@salesforce/label/c.FLNASCH_PGTM_Acknowledgement_Message';
import pgtmAdditionalAcknowledgementMessage from '@salesforce/label/c.FLNASCH_PGTM_Acknowledgement_Message_Additional';
import submitForProcessingContinueFlow from '@salesforce/label/c.FLNASCH_Submit_For_Processing_Continue_Flow';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { scrollToTop, sortByDay, sortData } from 'c/ldsUtils';

let today = new Date(Date.parse(new Date().toLocaleDateString(locale, {timeZone: timeZone})));
today.setDate(today.getDate() + 2);
const minDateFormatted = today.toISOString().split('T')[0];

const actions = [
    { label: 'Edit', name: 'edit' }
];

const columns = [
    { label: 'Day', fieldName: 'Day_of_Week__c', type: 'text', sortable: true },
    { label: 'Account/Facility', fieldName: 'Customer_Facility_Name__c', type: 'text', sortable: true },
    { label: 'Activity', fieldName: 'Activity_Type__c', type: 'text' },
    { label: 'Start Time', fieldName: 'Start_Time__c', type: 'formattedTime', sortable: true},
    { label: 'End Time', fieldName: 'End_Time__c', type: 'formattedTime' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];

export default class PgtmChangeRequest extends LightningElement {
    @api recordId;
    @api employeeId;
    @api employeeName;
    @api effectiveDate = minDateFormatted;
    @track minDateFormatted = minDateFormatted;
    @track data;
    @track dataClone;
    @track columns = columns;
    @track record = [];
    @track currentRecordId;
    @track bShowModal;
    @track showLoadingSpinner = true;
    @track showNestedSpinner;
    @track isAdd;
    @track currentRecordStatus = 'Modify';
    @track currentStartTime;
    @track currentEndTime;
    @track sortedBy = 'Day_of_Week__c';
    @track sortedDirection = 'asc';
    @track validationWarnings = [];
    @track validationErrors = [];
    @track errors = [];
    @track requestSubmitted;
    @api 
    validate() {
        let validationDetails = { 
            isValid: !!this.requestSubmitted
        };
        if(!this.requestSubmitted) {
            validationDetails.errorMessage = submitForProcessingContinueFlow;
        }
        return validationDetails;
    }
    @api preventInitiatedPgtmChangeRequests;
    @api availableActions = [];


    forceSubmit;
    refreshTable;
    initializedChangeRequests;
    
    labels = {
        saveLabel,
        cancelLabel,
        pgtmAcknowledgementMessage, 
        pgtmAdditionalAcknowledgementMessage
    };

    get showValidations() {
        return this.validationWarnings.length || this.validationErrors.length;
    }

    @wire(getActiveChangeRequests, { employeeScheduleId: '$recordId' })
    activeChangeRequests(result) {
        this.refreshTable = result;
        if(!(result.data || result.error)) {
            return;
        }
        if(result.data) {
            this.data = result.data;
            this.dataClone = JSON.parse(JSON.stringify(this.data));
            if(result.data.length > 0) {
                this.dataClone.forEach(row => {
                    row.Start_Time__c = this.toIsoFromMilliseconds(row.Start_Time__c);
                    row.End_Time__c = this.toIsoFromMilliseconds(row.End_Time__c);
                });
            } else {
                if(this.recordId != this.employeeId 
                    && !this.initializedChangeRequests 
                    && !this.preventInitiatedPgtmChangeRequests
                ) {
                    this.initiateChangeRequests();
                    return;
                }
            }
            this.initializedChangeRequests = true;
        } else if(result.error) {
            this.errors.push(result.error);
        }
        this.showLoadingSpinner = false;
    }

    initiateChangeRequests() {
        this.showLoadingSpinner = true;
        createPgtmChangeRequest({ employeeScheduleId: this.recordId })
        .then(() => {
            return refreshApex(this.refreshTable);
        })
        .catch(error => {
            this.errors.push(error);
            this.showLoadingSpinner = false;
        });
    }

    toIsoFromMilliseconds(milliseconds) {
        let time = new Date('1970-01-01');
        time.setMilliseconds(milliseconds);
        return time.toISOString().split('T')[1];
    }

    handleRowActions(event) {
        this.editCurrentRecord(event.detail.row);
    }

    editCurrentRecord(currentRow) {
        this.bShowModal = true;
        this.currentRecordId = currentRow.Id;        
        this.currentStartTime = currentRow.Start_Time__c;
        this.currentEndTime = currentRow.End_Time__c;
        this.isAdd = false;
        this.currentRecordStatus = 'Modify';
    }

    handleAddRecord() {
        this.bShowModal = true;
        this.currentRecordId = undefined;
        this.isAdd = true;
        this.currentRecordStatus = 'Add';
        this.currentStartTime = null;
        this.currentEndTime = null;
        this.forceSubmit = false;
        this.hasDataModified = true;
    }

    handleDiscardChanges() {
        let changeRequestIds = this.dataClone.map(record => record.Id).filter(x => x);
        if(!changeRequestIds || !changeRequestIds.length) {
            return;
        }
        this.showLoadingSpinner = true;
        this.errors = [];
        deleteChangeRequests({ changeRequestIds })
        .then(() => {
            this.validationWarnings = [];
            this.validationErrors = [];
            return refreshApex(this.refreshTable);
        })
        .catch(error => {
            this.errors.push(error);
            this.showLoadingSpinner = false;
        });
    }

    closeModal() {
        this.bShowModal = false;
    }
    
    startTimeUpdated(event) {
        this.currentStartTime = event.target.value;
    }

    endTimeUpdated(event) {
        this.currentEndTime = event.target.value;
    }

    handleAddEditRowSuccess() {
        this.bShowModal = false;
        this.showNestedSpinner = false;
        return refreshApex(this.refreshTable);
    }

    handleAddEditRowError() {
        this.showNestedSpinner = false;
    }

    handleAddEddRowFormSubmit(event) {
        this.showNestedSpinner = true;
        event.preventDefault();
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
        if(!allValid) {
            return;
        }
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    }

    updateColumnSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        const elements = [].slice.call(this.dataClone);
        if(fieldName === 'Day_of_Week__c') {
            this.dataClone = sortByDay(sortDirection, elements, 'Day_Number__c');
            return;
        } 
        this.dataClone = sortData(elements, fieldName, sortDirection);
    }

    submitForProcessing() { 
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
        if(!allValid) {
            return;
        }
        
        let changeRequestIds = this.data.map(row => {
            return row.Id;
        });
        let employeeId = this.employeeId;
        let effectiveDate = this.effectiveDate;
        this.showLoadingSpinner = true;
        this.validationWarnings = [];
        this.validationErrors = [];
        this.errors = [];
        submitForProcessing({
            changeRequestIds,
            employeeId,
            effectiveDate,
            forceSubmit: !!this.forceSubmit
        })
        .then(result => {
            refreshApex(this.refreshTable);
            this.handleSubmitProcessingResponse(result);
        })
        .catch(error => {
            this.errors.push(error);
            this.showLoadingSpinner = false;
        }); 
    }

    handleSubmitProcessingResponse(result) {
        if(result == 'Processed') {
            this.requestSubmitted = true;
            if (this.availableActions.find(action => action === 'NEXT')) {
                this.dispatchEvent(new FlowNavigationNextEvent());
                return;   
            }
            if (this.availableActions.find(action => action === 'FINISH')) {
                this.dispatchEvent(new FlowNavigationFinishEvent());
            }
            this.showLoadingSpinner = true;
            return;
        }
        let returnedValueObj = JSON.parse(result);
        this.validationWarnings = returnedValueObj.WARNINGS || [];
        this.validationErrors = returnedValueObj.ERRORS || [];
        this.forceSubmit = !this.validationErrors.length;
        this.showLoadingSpinner = false;
        scrollToTop();
    }
    get showAcknowledgementMessage(){
        return ((this.validationWarnings.length > 0 && this.validationErrors.length == 0)? true:false)
    }
}

