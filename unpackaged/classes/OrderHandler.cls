public class OrderHandler {
    
    public static order getOrderDetails(String orderId) {
        
        return [Select Id,OrderNumber,Type,Status,
                (Select Id,Product2.Name,Product2.ProductCode,Quantity,UnitPrice from OrderItems)
                From Order
                Where Id =:orderId ];
    }
    
    public static OrderDataWrapper getRequestBody(Order order) {
        if(order != null) {
            OrderDataWrapper requestbody = new OrderDataWrapper();
            requestbody.orderNumber = order.OrderNumber;
            requestbody.status = order.Status;
            requestbody.type = order.Type;
            List<OrderDataWrapper.OrderProducts> orderProductList = new List<OrderDataWrapper.OrderProducts>();
            if(order.orderItems != null && !order.orderItems.IsEmpty()) {
                for(OrderItem OrderItemRecord : order.orderItems) {
                    OrderDataWrapper.OrderProducts orderProduct = new OrderDataWrapper.OrderProducts();
                    orderProduct.code = 	 OrderItemRecord.Product2.ProductCode;
                    orderProduct.name =		 OrderItemRecord.Product2.Name;
                    orderProduct.quantity =  OrderItemRecord.Quantity;
                    orderProduct.unitPrice = OrderItemRecord.UnitPrice;
                    orderProductList.add(orderProduct);
                }
            }
            if(orderProductList != null && !orderProductList.isEmpty()) 
                requestbody.orderProducts = orderProductList;
            
            return requestbody;
        } else return new OrderDataWrapper();
        
    }

    public static HTTPResponse sendOrderDetail(String requestBody) {
        String EndPointUrl = System.Label.OrderSubmitEndPoint;
        HttpRequest RequestObject   = new HttpRequest();
        RequestObject.setEndpoint(EndPointUrl);
        RequestObject.setMethod('GET');
        Http http = new Http();
        HTTPResponse ResponseObject = http.send(RequestObject);
            
       return ResponseObject;
    }
    
    public static void afterOrderConfirmationProcess (string orderRecordId) {
        Order orderRecord = new Order();
        orderRecord.Id = orderRecordId;
        orderRecord.Status = 'Activated';
        Update OrderRecord;
        
        
    }
}