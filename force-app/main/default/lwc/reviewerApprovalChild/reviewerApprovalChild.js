import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getVFOrigin from '@salesforce/apex/Reviewer_Approval_Ctr.fetchVFDomainURL';


export default class ReviewerApprovalChild extends NavigationMixin(LightningElement) {
    @api scheduleRec;
    @api applicantemail;

    recId;
    showSave = false;
    showModal = false;
    showToast = false;
    selectedStatus = '';
    showButtons = false;
    showSpinner = false;
    vfPageDomain = '';
    connectedCallback() {
        this.showSpinner = true;
        this.recId = this.scheduleRec.Authorization_Location_Access_Schedule__c;
        this.showButtons = !(this.scheduleRec.Review_Completed__c);
        this.pathtoVFPage = '/apex/Reviewer_Approval_Page?polySchId='+this.scheduleRec.Id;
        getVFOrigin().then(result => {
            this.vfPageDomain = result;
        });

        window.addEventListener("message", (message) => {
            if(message.data.recId == this.scheduleRec.Id && message.origin === this.vfPageDomain){
                if (message.data.name === "PolygonModified"){
                    this.showSave = true;
                }
                if (message.data.name === "SendSaveStatus" && message.data.status == 'Update succesful'){
                    this.handleUpdateSuccess();
                }
            }
        });
        this.showSpinner = false;
    }

    handleUpdateSuccess(){
        this.showToast = true;
    }

    hideToast(){
        this.showToast = false;
    }
    openModal(){
        this.showModal = true;
    }

    handleSuccess(){
        this.showSpinner = true;
        this.dispatchEvent(new CustomEvent('updatestatus'));
        this.hideModal();
        this.hideToast();
        this.showButtons = false;
        this.showSpinner = false;
    }

    hideModal(){
        this.showModal = false;
    }

    updatePlotting(){
        this.showSpinner = true;
        this.template.querySelector("iframe").contentWindow.postMessage(this.scheduleRec.Id, this.vfPageDomain);
        this.showSpinner = false;
    }

    sendEmail(){
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName: "Global.SendEmail"
            },
            state: {
                recordId: this.scheduleRec.Id,
                defaultFieldValues:
                encodeDefaultFieldValues({
                    HtmlBody : '', 
                    Subject : 'Update : Your plotting has been updated',
                    ToAddress : this.applicantemail

                })
            }
        };
        this[NavigationMixin.Navigate](pageRef);
        this.showSave = false;
    }
}