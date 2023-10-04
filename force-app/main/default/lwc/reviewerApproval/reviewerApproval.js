import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPolySchedules from'@salesforce/apex/Reviewer_Approval_Ctr.getPolySchdules';
import getApplicantEmail from'@salesforce/apex/Reviewer_Approval_Ctr.getApplicantEmail';
import updateScheduleStatus from '@salesforce/apex/Reviewer_Approval_Ctr.updateScheduleStatus';
export default class ReviewerApproval extends LightningElement {

    @api recordId;
    @track locDetails;
    @track activeSections = [];
    applicantEmail;

    connectedCallback() {
        this.getSchedules();
        this.getEmail();
    }

    getSchedules(){
        let index=1;
        getPolySchedules({taskId : this.recordId})
        .then(result => {
            this.locDetails = JSON.parse(JSON.stringify(result));
            this.locDetails.forEach(function(loc){
                loc.Name = 'Area - '+index;
                loc.label = loc.Name+' ('+loc.Status__c+')'
                index++;
            });
            setTimeout(() => {
                if(!this.activeSections.length){
                    this.activeSections = [this.locDetails[0].Name];
                }
            }, 50);
        }).catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
    }

    getEmail() {
        getApplicantEmail({recordId : this.recordId})
        .then(result => {
            this.applicantEmail = result;
        })
        .catch(error => {
            console.log(error);
        });
    }

    updateStatus(){
        let recId = event.detail.recId;
        let selStatus = event.detail.statusVal;
        updateScheduleStatus({recordId : recId, statusVal : selStatus}).
        then(result => {
            this.showToast('Success', 'Operation succesful', 'success');
            this.getSchedules();
        }).error(error => {
            this.showToast('Error', err.body.message, 'error');
        });
    }

    showToast(title, msg, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}