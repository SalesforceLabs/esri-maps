import { LightningElement,api,track } from 'lwc';
import getLocationchedules from'@salesforce/apex/Applicant_License_Approved_Ctr.getLocationchedules';
export default class ApplicantLicenseApproved extends LightningElement {
    @api recordId;
    @track locDetails = [];
    @track activeSections = [];
    connectedCallback() {
        getLocationchedules({recordId : this.recordId})
        .then(result => {
            var count;
            for (let index = 0; index < result.length; index++) {
                count = index + 1;
                this.locDetails.push({"Name" : 'Schedule - '+count, "label" : 'Schedule - '+count, "Id" : result[index]});
            }
        })
        .finally(() => {
            setTimeout(() => {
                this.activeSections = [this.locDetails[0].Name];
            }, 50);
        })
    }


}