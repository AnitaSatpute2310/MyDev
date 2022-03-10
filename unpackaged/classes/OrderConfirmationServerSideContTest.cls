@isTest
public class OrderConfirmationServerSideContTest {
    @istest 
    public static void confirmOrderToSystemsPositive(){
        order orderRec = TestDataFactory.createOrders();
        PricebookEntry PBE = TestDataFactory.createPricebookEntry();
        List<orderItem> orderItemList = TestDataFactory.createOrderLineItem(orderRec,PBE);
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockRequestCatcherRespGenerator());
         string output = OrderConfirmationServerSideController.confirmOrderToSystems(orderRec.Id);
         System.assertEquals('Order Confirmed Successfully.!', output);
        test.stopTest();
    }
    
    @istest
    public static void confirmOrderToSystemsNegative(){
        order orderRec = TestDataFactory.createOrders();
        PricebookEntry PBE = TestDataFactory.createPricebookEntry();
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockRequestCatcherRespGenerator());
         string output = OrderConfirmationServerSideController.confirmOrderToSystems(orderRec.Id);
        // System.assertEquals('Order Confirmed Successfully.!', output);
        test.stopTest();
    }

}