/*Function : This is a server side controller for orderConfirmation LWC component.
 * This class is design to perform the fullfilment of order by sending the request to other systems 
 * if the success response (200 code)  then update order and its like items
 */
public with sharing class OrderConfirmationServerSideController {
	@AuraEnabled (cacheable=false)
    public static string confirmOrderToSystems(String orderId) { 		
        try {
			//get the order details by id
			Order orderRecord = OrderHandler.getOrderDetails(orderId);  
            if(orderRecord != null) {
                //Form the request body
                OrderDataWrapper requestBody = OrderHandler.getRequestBody(orderRecord);
                if(requestBody != null ) {
                     HTTPResponse HttpResonseObj = new HTTPResponse();
        			 HttpResonseObj = OrderHandler.sendOrderDetail(JSON.serialize(requestBody));
                    	if(HttpResonseObj.getStatusCode() == 200) {
                            OrderHandler.afterOrderConfirmationProcess(orderId);
                            return 'Order Confirmed Successfully.!';
                        }else {
                            throw new AuraHandledException('Connection Error,Please contact your administrator.');
                        }
                }
            }
        } catch(exception e) {
            throw new AuraHandledException('Connection Error Try again later.');
        }          
        
        return 'true';
    }
}