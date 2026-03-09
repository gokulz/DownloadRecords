import { LightningElement, wire } from 'lwc';
import getAllObjects from '@salesforce/apex/DownloadRecordsController.getAllObjects';
import getRecords from '@salesforce/apex/DownloadRecordsController.retrieveRecords';

export default class DownloadRecords extends LightningElement {

   columns = [];

    objList = [];
    isObjectList = false;
    selectedObj = '';
    showSearch = false;
    showTable = false;
    records = [];
    searchKey = '';

    @wire(getAllObjects)
    wiredGetAllObject({data, error}){
        if(data){
            this.objList = data.map(objName => ({
                 label : objName,
                 value : objName
            }));
            this.isObjectList = true;
            this.selectedObj = '';
            this.error = ''
        }else if(error){
            console.error('this object is not available');
        }
    }

    handleObjectChange(event){
        this.selectedObj = event.target.value;
        console.log('objects: ', this.selectedObj);
        this.showSearch = true;
        this.showTable = false;
    }

    get filteredObjectList(){
        if(!this.searchKey){
             return this.objList;
        }
        return this.objList.filter(obj => {
           return obj.label.toLowerCase().includes(this.searchKey.toLowerCase());
        })
    }

    
    handleSearch(event){
        this.searchKey = event.target.value;
    }



    /**
     * instead of wired i can use imperative call
     */

     searchRecords(){
          if(!this.selectedObj){
             return;
          }

          getRecords({
              objectName : this.selectedObj
          })
            .then(result => {
                // result is now a RecordsWrapper with nameField and records
                const nameField = result.nameField;


              //  this.records = result.records;
               this.records = result.records.map(rec =>{
                 return {
                    ...rec, 
                    recordName : rec[nameField]
                 };
               });

                // Build columns dynamically using the actual name field for this object
                this.columns = [
                    { label: 'Record Name', fieldName: 'recordName', type: 'text' },
                    { label: 'Record Id',   fieldName: 'Id',        type: 'text' },
                    { label: 'Created Date',       fieldName: 'CreatedDate',      type: 'date' },
                    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' }
                ];

              //c/downloadRecords  this.error = undefined;
                this.showTable = true;
            })
            .catch(error => {
               this.error = error;
               this.records = [];
               this.showTable = false;
            })
            
     }
}