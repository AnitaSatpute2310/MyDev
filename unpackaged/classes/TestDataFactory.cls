@isTest
public class TestDataFactory {
    public static Account createAccount() {
         Account a = new Account();
         a.Name = 'Test Account';
         insert a;
        return a;
    }
    public static Product2 createProduct(){
		Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
        return p;
    }
    
    public static Id getPricebookId() {
        Id pricebookId = Test.getStandardPricebookId();
		return pricebookId;
    }
    
    public static PricebookEntry createPricebookEntry () {
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = TestDataFactory.getPricebookId();
        Product2 prodduct2Rec = new Product2();
        prodduct2Rec = TestDataFactory.createProduct();
        standardPrice.Product2Id = prodduct2Rec.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        return standardPrice;
    }
    public static PricebookEntry createPricebookEntrywithProd(string prodduct2Id) {
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = TestDataFactory.getPricebookId();
        standardPrice.Product2Id = prodduct2Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        return standardPrice;
    }
    public static Order createOrders() {
        Order orderRec = new Order();
        orderRec.Name = 'Test Order ';
        orderRec.Status = 'Draft';
        orderRec.EffectiveDate = system.today();
        orderRec.EndDate = system.today() + 4;
        orderRec.AccountId = TestDataFactory.createAccount().id;
        orderRec.Pricebook2Id =  TestDataFactory.getPricebookId();
        insert orderRec;
        return orderRec;
    }
    
    public static List<OrderItem> createOrderLineItem(Order orderRec,PricebookEntry priceBookEntryRec) {
        List<orderItem> orderItemList = new List<OrderItem>();
        for(integer i=0;i<6;i++) {
            OrderItem orderItemRec = new OrderItem();
            orderItemRec.OrderId = orderRec.id;
            orderItemRec.Quantity = 24;
            orderItemRec.UnitPrice = 240;
            orderItemRec.Product2id = TestDataFactory.createProduct().id;
            orderItemRec.PricebookEntryId=priceBookEntryRec.id;
            orderItemList.add(orderItemRec);
        }
        insert orderItemList;
        return orderItemList;
    }
}