import { LightningElement, api, wire } from 'lwc';
import getVFOrigin from '@salesforce/apex/Basic_Map_Reviewer_Approval_Ctr.fetchVFDomainURL';
import getPolygonSchedule from '@salesforce/apex/Basic_Map_Reviewer_Approval_Ctr.getPolygonSchedule'

export default class BasicMapReviewerApproval extends LightningElement {
    @api recordId;
    @api scheduleRec;

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

        getPolygonSchedule({recordId : this.recordId}).then(result => {
            this.scheduleRec = result;
            this.recId = this.scheduleRec.Id;
            this.showButtons = !(this.scheduleRec.Review_Completed__c);
            
        })
        
       
        this.pathtoVFPage = '/apex/Basic_Map_Reviewer_Approval_Page?recordId='+this.recordId;
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
        this.showSave = false;
    }
    openModal(){
        this.showModal = true;
    }

    handleSuccess(){

        this.showSpinner = true;
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



  
   

}
