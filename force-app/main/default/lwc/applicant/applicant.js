import { LightningElement,api,track } from 'lwc';
import getPolySchedules from'@salesforce/apex/Applicant_Ctr.getPolySchdules';

export default class Applicant extends LightningElement {
    @api recordId;
    @track locDetails;
    @track activeSections = [];
    connectedCallback() {
        getPolySchedules({recordId : this.recordId})
        .then(result => {
            this.locDetails = result;
            let index = 1;
            this.locDetails.forEach(function(loc){
                loc.Name = 'Schedule - '+index;
                loc.label = loc.Name;
                index++;
            });
        }).finally(() => {
            setTimeout(() => {
                this.activeSections = [this.locDetails[0].Name];
            }, 50);
        })
    }
}