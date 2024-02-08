import { LightningElement,api } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BasicMapCreate extends OmniscriptBaseMixin(LightningElement)  {
    @api obj;
    @api saveandaddmore;
    pathtoVFPage = '';
    receivedMessage = '';
   
    loc = '';
    @api locDetail = '';
   
    addNewEntry = false;
    showDelete = false;
    vfPageDomain = '';
   
    fetchMap(){
                
                
                this.showMap = true;
                this.btnLabel = 'Refresh Availability';

                defaultAddressCoordinates({inputAddress:this.omniJsonData.address}).then(result => {
                    this.coords =result;
                });

                let msg = {
                        title : 'fetchDetails',
                        detail : this.coords
                    }
                this.handleFiretoVF(JSON.stringify(msg)); 
         /*   } 
        } */
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
                this.showToast(paramData.title,paramData.msg,paramData.variant);
            } else {
                this.omniUpdateDataJson(this.locDetail.dataRecd);

                let paramData = {title:'Success', msg: 'Save succesful', variant : 'success'};
                
                this.showToast(paramData.title,paramData.msg,paramData.variant);

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
        
        this.pathtoVFPage = '/apex/Basic_Map_Create_Page?latitude=' + this.omniJsonData.Latitude + '&longitude=' + this.omniJsonData.Longitude;
           
        this.vfPageDomain = window.location.origin+'/';

        window.addEventListener("message", (message) => {
            if (message.data.name === "storeDetails" && message.data.location == this.locDetail.name) {
                this.receivedMessage = message.data.payload;
                this.locDetail.dataRecd = JSON.parse(this.receivedMessage);
                this.captureEntry();
            }
 
            if(message.data.name == 'pageLoaded' ){
                

                let msg = {
                    title : 'fetchDetails',
                    detail : 'fetchDetails'
                }
                this.handleFiretoVF(JSON.stringify(msg));
            }
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