import { LightningElement,api, wire, track } from 'lwc';
import getAuditHistoryRecords from '@salesforce/apex/AuditHistoryController.getAuditHistoryRecords';
import { getRecord } from 'lightning/uiRecordApi';
import REVENUE_FIELD from '@salesforce/schema/OpportunityLineItem.UnitPrice';

const fields = [REVENUE_FIELD];

const columns = [
    { label: 'Date', fieldName: 'CreatedDate'},
    { label: 'Field Name', fieldName: 'FieldName'},
    { label: 'User', fieldName: 'UserName', type: 'text'},
    { label: 'Previous Value', fieldName: 'OldValue', type: 'text'},
    { label: 'New Value', fieldName: 'NewValue', type: 'text'}
];

export default class AuditHistoryLwc extends LightningElement {

    @api recordId;
    @track data = [];
    @track errors = [];
    @track showLoadingSpinner = true;
    @track rowsByFieldName = [];
    columns = columns;

    @wire(getRecord, { recordId: '$recordId', fields})
    oppProductAuditHistory(record){
        if(record.data){
            this.getOppProductAuditHistory();
        }
    }

    getOppProductAuditHistory(){
        this.errors =[];
        getAuditHistoryRecords({oppProductId: this.recordId})
        .then((result) => {
            let currentData = [];
            result.forEach((row) => {
                let rowData = {};
                rowData.CreatedDate = new Date(row.CreatedDate).toLocaleDateString() + ' ' +new Date(row.CreatedDate).toLocaleTimeString() ;
                rowData.FieldName = row.Field_Name__c;
                rowData.UserName = row.Owner.Name;
                rowData.OldValue = row.Old_value__c;
                rowData.NewValue = row.New_Value__c;
                currentData.push(rowData);
            });
            this.data = currentData;
            this.rowsByFieldName = this.generateKeyWithUniqueValues(this.data);
            console.log(this.rowsByFieldName);
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.errors.push(error);
            this.showLoadingSpinner = false;
        });
    }
    
    generateKeyWithUniqueValues(incomingData) {
        var generateMap = new Map();
        var arrayData = [];
        incomingData.forEach(row => {
            if(generateMap.has(row.FieldName)) {
                let lt = generateMap.get(row.FieldName);
                lt.push(row);
                generateMap.set(row.FieldName, lt); 
            }
            else {
                generateMap.set(row.FieldName, [row]); 
            }
        });
        generateMap.forEach( (value, key, map) => {
            arrayData.push({value:value, key:key}); 
        });
        return arrayData;
    }
}