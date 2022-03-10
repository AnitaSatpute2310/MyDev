@isTest
public class OrderableProductDetailsControllerTest {
	@istest 
    public static void confirmOrderToSystemsPositive(){
    	order orderRec = TestDataFactory.createOrders();
        Product2 productRec = TestDataFactory.createProduct();
        PricebookEntry PBE = TestDataFactory.createPricebookEntry();      
        List<orderItem> tobeInsertedList = new List<orderItem>();
        tobeInsertedList.add(new OrderItem(Product2Id= productRec.id,
                                               UnitPrice=100,
                                               Quantity=1,
                                           	   OrderId=orderRec.Id));
        
        test.starttest();
        	List<orderItem> orderItemList = TestDataFactory.createOrderLineItem(orderRec,PBE);
			OrderableProductDetailsController.retrieveProducts();
        	OrderableProductDetailsController.retrievePriceBookEntry();
        	OrderableProductDetailsController.getPriceBookEntryData(TestDataFactory.getPricebookId());
        	OrderableProductDetailsController.getOrderItemsData(orderRec.Id);
        	OrderableProductDetailsController.addOrderItemRecords(tobeInsertedList,orderRec.Id,TestDataFactory.getPricebookId());
        test.stopTest();
    }
    @istest 
    public static void confirmOrderToSystemsPositiveElse(){
    	order orderRec = TestDataFactory.createOrders();
        Product2 productRec = TestDataFactory.createProduct();
        PricebookEntry PBE = TestDataFactory.createPricebookEntrywithProd(productRec.Id);      
        List<orderItem> tobeInsertedList = new List<orderItem>();
        tobeInsertedList.add(new OrderItem(Product2Id= productRec.id,
                                               UnitPrice=100,
                                               Quantity=1,
                                           	   OrderId=orderRec.Id));
        
        test.starttest();
        	List<orderItem> orderItemList = TestDataFactory.createOrderLineItem(orderRec,PBE);
			OrderableProductDetailsController.retrieveProducts();
        	OrderableProductDetailsController.retrievePriceBookEntry();
        	OrderableProductDetailsController.getPriceBookEntryData(TestDataFactory.getPricebookId());
        	OrderableProductDetailsController.getOrderItemsData(orderRec.Id);
        	OrderableProductDetailsController.addOrderItemRecords(tobeInsertedList,orderRec.Id,TestDataFactory.getPricebookId());
        test.stopTest();
    }
}