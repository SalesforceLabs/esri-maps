import { LightningElement,api } from 'lwc';
import getVFDomain from '@salesforce/apex/Applicant_Create_Ctr.fetchCommunityURL';

export default class ApplicantCreateChild extends LightningElement {
    @api obj;
    @api saveandaddmore;
    pathtoVFPage = '';
    receivedMessage = '';
    showMap = false;
    loc = '';
    @api locDetail = '';
    btnLabel = 'Select Location';
    addNewEntry = false;
    showDelete = false;
    vfPageDomain = '';
    fetchMap(){
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return validSoFar && inputField.reportValidity();
            }, true);
        if (isInputsCorrect) {
            
            let splitstrtDate = this.locDetail.strtDate.split('-');
            let splitstrtTime = this.locDetail.strtTime.split(':');

            let splitendDate = this.locDetail.endDate.split('-');
            let splitendTime = this.locDetail.endTime.split(':');

            let formattedStrtDateTime = new Date(splitstrtDate[0], splitstrtDate[1]-1, splitstrtDate[2],  splitstrtTime[0], splitstrtTime[1]);
            let formattedEndDateTime = new Date(splitendDate[0], splitendDate[1]-1, splitendDate[2],  splitendTime[0], splitendTime[1]);

            if(formattedStrtDateTime >=  formattedEndDateTime){
                let paramData = {title:'Error', msg: 'End Date Time must be after Start Date Time', variant : 'error'};
                let errorEv = new CustomEvent('showtoast', 
                                        {detail : paramData}
                                        );
                this.dispatchEvent(errorEv);
            } else {
                this.showMap = true;
                this.btnLabel = 'Refresh Availability';
                let msg = {
                        title : 'fetchDetails',
                        detail : this.locDetail
                    }
                this.handleFiretoVF(JSON.stringify(msg)); 
            } 
        }
    }

    handleChange(event){
        this.locDetail[event.target.name] = event.target.value;
        this.showMap = false;
        this.locDetail.dataRecd = {};
    }

    handleFiretoVF(msg) {
        this.template.querySelector("iframe").contentWindow.postMessage(msg, this.vfPageDomain);
    }

    
    storeEntry(){
        let msg = {
            title : 'captureDetails',
            detail : { name : this.locDetail.name }
        }
        this.handleFiretoVF(JSON.stringify(msg));
        if(event.target.name == 'addEntry'){
            this.addNewEntry = true;
        }
    }

    captureEntry(){
        if(this.locDetail.dataRecd) {
            if(this.locDetail.dataRecd.hasOwnProperty('error')){
                let paramData = {title:'Error', msg: this.locDetail.dataRecd.error, variant : 'error'};
                let errorEv = new CustomEvent('showtoast', 
                                        {detail : paramData}
                                        );
                this.dispatchEvent(errorEv);
            } else {
                let paramData = {title:'Success', msg: 'Save succesful', variant : 'success'};
                let sucEv = new CustomEvent('showtoast', 
                                        {detail : paramData}
                                        );
                this.dispatchEvent(sucEv);
                if(this.addNewEntry){
                    let newEntry = new CustomEvent('addentry', {});
                    this.dispatchEvent(newEntry);
                }
                
            }
        } 
        this.addNewEntry = false;
    }

    @api fetchDetails(){
        return this.locDetail;
    }

    removeEntry(){
        let paramData = {locName : this.locDetail.name};
        this.dispatchEvent(new CustomEvent('removeentry', {detail : paramData}));
    }
    connectedCallback() {
        this.locDetail = {...this.obj};
        getVFDomain().then(result => {
            this.pathtoVFPage = '/apex/Applicant_Create_Page';
            this.vfPageDomain = result+'/';
        });
        window.addEventListener("message", (message) => {
            if (message.data.name === "storeDetails" && message.data.location == this.locDetail.name) {
                this.receivedMessage = message.data.payload;
                this.locDetail.dataRecd = JSON.parse(this.receivedMessage);
                this.captureEntry();
            }

            if(message.data.name == 'pageLoaded' && !Object.keys(this.locDetail.dataRecd).length){
                let msg = {
                    title : 'fetchDetails',
                    detail : this.locDetail
                }
                this.handleFiretoVF(JSON.stringify(msg));
            }
        });
        this.showDelete = this.locDetail.name != 'Loc0001';
    }
}