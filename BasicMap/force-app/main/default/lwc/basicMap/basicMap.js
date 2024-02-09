import { LightningElement,api } from 'lwc';
import basePath from '@salesforce/community/basePath';

export default class BasicMap extends LightningElement {
    @api recordId;

    connectedCallback() {
   
        if (basePath.length == 2){
            this.pathtoVFPage = '/apex/Basic_Map_Page?applicationId='+this.recordId; 
        }
        else {
            this.pathtoVFPage = basePath.substring(0,basePath.length-2) + '/apex/Basic_Map_Page?applicationId='+this.recordId;
        }
    }   
}