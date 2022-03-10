public class OrderableProductDetailsController {
	@AuraEnabled (cacheable=true)
    public static List<Product2> retrieveProducts(){
        return [SELECT Id, Name
                FROM Product2
                LIMIT 1000];
    }
    
    @AuraEnabled (cacheable=true)
    public static List<PricebookEntry> retrievePriceBookEntry() {
        return [SELECT Id,IsActive,Pricebook2Id,pricebook2.Name,pricebook2.isstandard,Product2.Name,UnitPrice 
                FROM PricebookEntry];
    }
    
     @AuraEnabled (cacheable=true)
    public static List<PricebookEntry> getPriceBookEntryData(String priceBookId) {
        return [SELECT Id,IsActive,Pricebook2Id,pricebook2.Name,pricebook2.isstandard,Product2.Name,UnitPrice 
                FROM PricebookEntry
                WHERE Pricebook2Id =: priceBookId];
    }
    
    @AuraEnabled (cacheable=false)
    public static List<OrderItem> getOrderItemsData (String orderId) {
        return [Select Id,Product2Id,Product2.Name,UnitPrice,TotalPrice,Quantity,OrderId
                From OrderItem 
                WHERE orderId =: orderId];
    }
    
    @AuraEnabled (cacheable=false)
    public static boolean addOrderItemRecords (List<orderItem> orderItemRecordList, String orderId, String PricebookId) {
        system.debug('orderItems:'+orderItemRecordList);
        boolean isSuccessful = true;
        List<OrderItem> toBeInsertedOrderItemsList = new List<OrderItem>();
        Map<Id,orderItem> toBeUpdatedOrderItemsMap = new Map<Id,orderItem>();
        Map<Id,orderItem> existingOrderItemRecordsMap = new Map<Id,orderItem>();
        for(orderItem orderitemRec : [Select id,Product2Id,Quantity,OrderId From OrderItem WHERE orderId =: orderId]) {
            existingOrderItemRecordsMap.put(orderitemRec.Product2Id,orderitemRec);
        }
        Map<Id,PricebookEntry> pricebookIdMap = new Map<Id,PricebookEntry>();
        for(PricebookEntry pricebookEntryRec : [Select id,Pricebook2Id,Product2Id from PricebookEntry WHERE Pricebook2Id =: PricebookId ]) {
            pricebookIdMap.put(pricebookEntryRec.Product2Id,pricebookEntryRec);
        }
        for(orderItem newOrderItemRec : orderItemRecordList) {
           if(existingOrderItemRecordsMap.containskey(newOrderItemRec.Product2Id)) {
               orderItem toBeUpdatedOrderItemRec = new orderItem();
               toBeUpdatedOrderItemRec.id = existingOrderItemRecordsMap.get(newOrderItemRec.Product2Id).Id;
               toBeUpdatedOrderItemRec.Quantity = existingOrderItemRecordsMap.get(newOrderItemRec.Product2Id).Quantity+1;                
               toBeUpdatedOrderItemsMap.put(toBeUpdatedOrderItemRec.Id,toBeUpdatedOrderItemRec);
            }else {
                orderItem toBeInsertedOrderItemRec = new orderItem();
                toBeInsertedOrderItemRec.Quantity = newOrderItemRec.Quantity;
               	toBeInsertedOrderItemRec.Product2id = newOrderItemRec.Product2Id;
                toBeInsertedOrderItemRec.UnitPrice = newOrderItemRec.UnitPrice;
                toBeInsertedOrderItemRec.orderId= newOrderItemRec.OrderId;
                toBeInsertedOrderItemRec.ListPrice = newOrderItemRec.UnitPrice;
                if(pricebookIdMap.containskey(newOrderItemRec.Product2Id)) {
                     toBeInsertedOrderItemRec.PricebookEntryId = pricebookIdMap.get(newOrderItemRec.Product2Id).Id;
                }                                  
                toBeInsertedOrderItemsList.add(toBeInsertedOrderItemRec);
			}
        }
        if(toBeInsertedOrderItemsList != null && !toBeInsertedOrderItemsList.isEmpty()){
             isSuccessful = utilityClass.insertOrderItemList(toBeInsertedOrderItemsList);
        }
        if(toBeUpdatedOrderItemsMap != null && !toBeUpdatedOrderItemsMap.isEmpty()){
            isSuccessful= utilityClass.updateOrderItemList(toBeUpdatedOrderItemsMap);
        }
                 
        return isSuccessful;
    }

}