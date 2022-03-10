global with sharing class OrderDataWrapper {
    
    global String accountNumber;
    global string orderNumber;
    global String type;
    global String status;
    global List<OrderProducts> orderProducts;
    
    global class OrderProducts{
        global String name;
        global String code;
    	global decimal unitPrice;
    	global decimal quantity;
	}
    
}