import { LightningElement, api } from 'lwc';

export default class ApplicantChild extends LightningElement {
    @api scheduleRec;
    recId;
    connectedCallback() {
        this.recId = this.scheduleRec.Id;
        this.pathtoVFPage = '/apex/Applicant_Page?authLocationId='+this.scheduleRec.Id;
    }   
}