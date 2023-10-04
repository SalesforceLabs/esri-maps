import { LightningElement,api } from 'lwc';
export default class ApplicantLicenseApprovedChild extends LightningElement {
    @api scheduleRec;
    scheduleRecId;
    connectedCallback() {
        this.scheduleRecId = this.scheduleRec.Id;
        this.pathtoVFPage = '/apex/Applicant_License_Approved_Page?authLocationId='+this.scheduleRec.Id;
    }   
}