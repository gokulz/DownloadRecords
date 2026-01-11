import { LightningElement, wire } from 'lwc';
import getAllObjects from '@salesforce/apex/DownloadRecordsController.getAllObjects';

export default class DownloadRecords extends LightningElement {

    objList = [];
    isObjectList =false;
    selectedObj = '';
    showSearch = false;

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
    }

    handleClick(){
        console.log('selcetedobject: ' , this.selectedObj);
    }

    

}