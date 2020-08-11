import { LightningElement, track, api } from 'lwc';


export default class Paginator extends LightningElement {

    @track page = 1; 
    @track originalDataClone = [];
    @api columns ; 
    @track firstRecord = 1; 
    @track lastRecord = 0; 
    @track defaultPageSize = 5; 
    @track totalRecordsCount = 0; 
    @track totalNumberOfPages = 0; 


    _originalData;
    @api
    get originalData(){
        return this._originalData;
    }
    set originalData(value){
        this._originalData = value;
        this.inititatePagination();
        return;
    }

    inititatePagination(){
        
        if(this._originalData){
            this.originalDataClone = this._originalData;
            this.totalRecordsCount = this._originalData.length; 
            this.totalNumberOfPages = Math.ceil(this.totalRecordsCount / this.defaultPageSize); 
            this._originalData = this.originalDataClone.slice(0,this.defaultPageSize); 
            this.lastRecord = this.defaultPageSize;
            this.error = undefined;
        }
    }

    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.displayRecordPerPage(this.page);
        }
    }

    handleNext() {
        if((this.page<this.totalNumberOfPages) && this.page !== this.totalNumberOfPages){
            this.page = this.page + 1; 
            this.displayRecordPerPage(this.page);            
        }      
    }

    
    displayRecordPerPage(page){
        this.firstRecord = ((page -1) * this.defaultPageSize) ;
        this.lastRecord = (this.defaultPageSize * page);

        this.lastRecord = (this.lastRecord > this.totalRecordsCount) 
                            ? this.totalRecordsCount : this.lastRecord; 

        this._originalData = this.originalDataClone.slice(this.firstRecord, this.lastRecord);
        this.firstRecord = this.firstRecord + 1;
    }    
}