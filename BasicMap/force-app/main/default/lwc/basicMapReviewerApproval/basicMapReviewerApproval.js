import { LightningElement, api, wire } from 'lwc';
import getVFOrigin from '@salesforce/apex/Basic_Map_Reviewer_Approval_Ctr.fetchVFDomainURL';
import getMyOrigin from '@salesforce/apex/Basic_Map_Reviewer_Approval_Ctr.fetchMyDomainURL';
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
    MyPageDomain = '';
    vfPageDomainResend = '';

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

        getMyOrigin().then(result => {
            this.MyPageDomain = result;
        })

        window.addEventListener("message", (message) => {
            /*
            console.log("scheduleRec.Id is "+ this.scheduleRec.Id );
            console.log("message.data.recId is "+ message.data.recId);
            console.log("message.origin is " + message.origin);
            console.log("vfPageDomain is " + this.vfPageDomain);
            console.log("message.data.name is "+message.data.name);
            console.log("MyPageDomain is "+this.MyPageDomain);*/
            this.vfPageDomain2 = message.origin;
            //Added to handle Orgs where the origin is set as my.salesforce.com instead of --c.vf.force.com
            if(message.data.recId == this.scheduleRec.Id && (message.origin === this.vfPageDomain || message.origin === this.MyPageDomain)){
               
                if (message.data.name === "PolygonModified"){
                    this.vfPageDomainResend = message.origin;
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
        this.template.querySelector("iframe").contentWindow.postMessage(this.scheduleRec.Id, this.vfPageDomainResend);
        this.showSpinner = false;
    }



  
   

}
