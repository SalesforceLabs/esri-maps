import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApplicantCreate extends OmniscriptBaseMixin(LightningElement) {
    pathtoVFPage = '';
    receivedMessage = '';
    mapVal = {};
    showMap = false;
    loc = '';
    btnLabel = 'Select Location';
    @track locArray = [];
    @track storedLocArray = [];
    @track activeSections = [];
    @track allowMultipleLocations;

    addEntry(){
        let index = this.locArray.length+1;
        const locDetails = {
            strtDate : "",
            strtTime : "",
            endDate : "",
            endTime : "",
            name : "Loc000"+index,
            dataRecd : ""
        }
        this.locArray.push(locDetails);
        setTimeout(() => {
            this.activeSections = [locDetails.name];    
        }, 50);
    }

    removeEntry(event) {
        let recdName = event.detail.locName;
        this.locArray = this.locArray.filter(item => item.name !== recdName)
    }

    connectedCallback() {
        this.allowMultipleLocations = this.omniJsonData['allowMultipleLocations'];
        this.addEntry();
    }

    handlePrevClick(){
        this.omniPrevStep();
    }

    handleNextClick(){
        let locDetails = [];
        this.template.querySelectorAll('c-applicant-create-child').forEach(element => {
            let elemDetails = element.fetchDetails();
            let elemGeometry = elemDetails.dataRecd.geometry;
            locDetails.push(elemDetails);
        });
        let isDataValid = false;
        locDetails.forEach(element => {
            isDataValid = element.strtDate && element.strtTime && element.endDate && element.endTime
             && element.dataRecd && element.dataRecd.hasOwnProperty('geometry');
            if(!isDataValid){
                return;
            }
        });
        if(isDataValid){
             let dataFromLWC = {"locDetails" : locDetails};
             this.omniUpdateDataJson(dataFromLWC);
             this.omniNextStep();
        } else {
            this.showToast('Error', 'Please fill all the required fields and click on Save for every individual section', 'error');
        }
    }

    showToastFromChild(event){
        this.showToast(event.detail.title, event.detail.msg, event.detail.variant);
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