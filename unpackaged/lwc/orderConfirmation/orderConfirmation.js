import { LightningElement, track,wire,api } from 'lwc';
import { getRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ORDERSTATUS from '@salesforce/schema/Order.Status';
import PRICEBOOK_ID from '@salesforce/schema/Order.Pricebook2Id';
import orderConfirmationProcess from '@salesforce/apex/OrderConfirmationServerSideController.confirmOrderToSystems';
import { refreshApex } from '@salesforce/apex';


export default class orderConfirmation extends LightningElement {
    @api recordId;
    @track showTable = true;
    @wire(getRecord, { recordId: '$recordId', fields: [PRICEBOOK_ID,ORDERSTATUS] })
    orderData({ error, data }){
        if(data){
            this.ORDERSTATUS =data.fields.Status.value;
            this.PRICEBOOK_ID =data.fields.Pricebook2Id.value;
            if(this.ORDERSTATUS == 'Activated') {
                this.showTable = false;
            }
            if(!this.PRICEBOOK_ID ){
                this.showTable = false;
            }
        }
    }
    confirmOrder() {
        console.log('consition pass');
        orderConfirmationProcess({
            orderId: this.recordId
        })
        .then(result => {
            if(result.includes('Successfully')){
                //console.log(JSON.stringify(result));
                getRecordNotifyChange([{recordId: this.recordId}]);
                const evt = new ShowToastEvent({
                    title: 'Successful',
                    message: 'Order Confirmed Successfully',
                    variant: 'Success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);               
                    
            }else {
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: 'Something went wrong, Contact administrator.!',
                    variant: 'error',
                    mode: 'dismissable'
                });
                    this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
}