import { LightningElement ,track,wire,api  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import PRICEBOOK_ID from '@salesforce/schema/Order.Pricebook2Id';
import PRICEBOOK_ACTIVE from '@salesforce/schema/Order.Pricebook2.IsActive';
import ORDERSTATUS from '@salesforce/schema/Order.Status';
import getProductData from '@salesforce/apex/OrderableProductDetailsController.getPriceBookEntryData';
import addOrderProducts from '@salesforce/apex/OrderableProductDetailsController.addOrderItemRecords';
import { publish, MessageContext } from 'lightning/messageService';
import refreshRealtedList from '@salesforce/messageChannel/refreshRelatedList__c';

const columns = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'List Price',fieldName: 'UnitPrice'}
];
export default class OrderProductOperations extends LightningElement {

    @api recordId;
    @track columns; 
    @track productData = [];
    @track showTable=true;
    @track showButton=true;
    @track orderItemProducts = [];
    //Pagination Attributes 
    @track page = 1;
    @track items = []; 
    @track startingRecord = 1; 
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0; 
    @track totalPage = 0; 

    @wire(getRecord, { recordId: '$recordId', fields: [PRICEBOOK_ID,ORDERSTATUS] })
    orderData({ error, data }){
       if(data){
            
            console.log('recordId:'+this.recordId);
            this.PRICEBOOK_ID =data.fields.Pricebook2Id.value;
            this.ORDERSTATUS =data.fields.Status.value;
            if(this.ORDERSTATUS == 'Activated') {
                this.showButton = false;
            }
            if(this.PRICEBOOK_ID ){
                console.log('inside');
                getProductData({
                    priceBookId: this.PRICEBOOK_ID
                })
                .then(result => {
                    for (let itdtCol of result) {
                        this.columns = columns;
						this.items.push({Name: itdtCol.Product2.Name,UnitPrice: itdtCol.UnitPrice,id: itdtCol.Product2Id});
					}
                    this.totalRecountCount = result.length; 
                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                    this.productData = this.items.slice(0,this.pageSize);
                    this.endingRecord = this.pageSize;
                })
                .catch(error => {
                    this.ShowToastEvent('Browser Issue','Some unexpected error','error');
			        this.showTable = false;
                }); 
                
            }else {
                let message = 'Order Doesnot have Pricebook associated with it.!';
                this.ShowToastEvent('Error',message,'error');
                this.showTable = false;
            }
        
        } 
       else if (error) {
        console.log(error);
        this.error = error;
        }
    }
    @wire(MessageContext) 
    messageContext;

    //Pagination Code 
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.displayRecordPerPage(this.page);
        }
    }
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; 
            this.displayRecordPerPage(this.page);            
        }             
    }
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        this.productData = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    


    handleclick(){
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        //console.log('selected:'+selected);
        if(selected.length ==0) {
            let message = 'Please Select Product first.!';
            this.ShowToastEvent('Error',message,'error');
                         
        }else {
            for (let selectedRec of selected) {
                this.orderItemProducts.push({
                    sObjectType: 'OrderItem',
                    Product2Id: selectedRec.id,
                    UnitPrice: selectedRec.UnitPrice,
                    Quantity:1,
                    OrderId:this.recordId});
            }
            
            //console.log('Data:'+JSON.stringify(this.orderItemProducts));
            if(this.orderItemProducts){
                addOrderProducts({
                    orderItemRecordList: this.orderItemProducts,
                    orderId: this.recordId,
                    PricebookId: this.PRICEBOOK_ID
                })
                .then(result => {
                   console.log('Successful!');
                   if(result) {
                        const payload = { recordId: this.recordId};
                        publish(this.messageContext, refreshRealtedList, payload);
                        console.log('Event Published..!');   
                        this.ShowToastEvent('Successful','Order Products Added Or Updated Successfully');
                    }else {
                        this.ShowToastEvent('Browser Issue','Upsert failed','error');
                    }
                })
                .catch(error => {
                    this.ShowToastEvent('Browser Issue','Addition Failed','error');
                    console.log(error);
			    });
            }
        }
    }
    ShowToastEvent(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant||'success',
                mode: 'dismissable'
            })
        );
    }

}