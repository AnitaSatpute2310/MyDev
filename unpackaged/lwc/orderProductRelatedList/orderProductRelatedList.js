import { LightningElement,track,wire,api} from 'lwc';
import { getRecord ,getRecordNotifyChange} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PRICEBOOKREC_ID from '@salesforce/schema/Order.Pricebook2Id';
import { refreshApex } from '@salesforce/apex';
import orderProductsData from '@salesforce/apex/OrderableProductDetailsController.getOrderItemsData';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import refreshRealtedList from '@salesforce/messageChannel/refreshRelatedList__c';

const columns = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'Unit Price',fieldName: 'UnitPrice'},
    { label: 'Quantity',fieldName: 'Quantity'},
    { label: 'Total Price',fieldName: 'TotalPrice'}
];
export default class OrderProductRelatedList extends LightningElement {
    @api recordId;
    @track columns;
    @track showTable=true;
    @track productData =[];

    @wire(MessageContext)
    messageContext;
    receivedMessage;
    subscription = null;
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                refreshRealtedList,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleMessage(message) {
        this.recordId = message.recordId;
        this.receivedMessage = message ? JSON.stringify( message, null, '\t' ) : 'no message payload';
    }
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PRICEBOOKREC_ID] })
    orderRecordData({ error, data }){
        if(data){
            this.PRICEBOOKREC_ID =data.fields.Pricebook2Id.value;
            console.log('inside Related LWC');
            if(this.PRICEBOOKREC_ID){
                console.log('inside orderitem data'+this.recordId);
                orderProductsData({
                    orderId: this.recordId
                })
                .then(result => {
                   // console.log('datafrombackend:'+JSON.stringify(result));
                    this.showTable=true;
                    this.productData=[]; //To update the data from backend
                    if(result.length ==0) {
                       this.showTable = false;
                       console.log('Size 0');
                    }else{
                        for (let recdata of result) {
                          this.columns = columns;
                          this.productData.push({Name:recdata.Product2.Name,UnitPrice: recdata.UnitPrice,id: recdata.Product2Id,Quantity: recdata.Quantity,TotalPrice: recdata.TotalPrice});
                        }
                   }
                   getRecordNotifyChange([{recordId: this.recordId}]);


                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    const evt = new ShowToastEvent({
                        title: 'Browser Issue',
                        message: 'Unexpected Error Occured, Contact Administrator.!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                        this.dispatchEvent(evt);
                        this.showTable = false;
                }); 
            }else {
                this.showTable = false;
            }
        }
    }
}