public class CancelSalesOrder implements Queueable,Database.AllowsCallouts {
    
    public static String cancelEndpoint;    
    public static Map<String,Object> mapResponse;
    public String token;
    public String saleOrderCode;
    public String cancellationReason;
    public String orderStatus;
    public List<Opportunity> lstSalesOrders = new List<Opportunity>();
    
    public CancelSalesOrder(String saleOrderCode,String cancellationReason,List<Opportunity> lstSalesOrders,String orderStatus){
        this.saleOrderCode = saleOrderCode;
        this.cancellationReason = cancellationReason;
        this.lstSalesOrders = lstSalesOrders;
        this.orderStatus = orderStatus;
    }
    
    public void execute(QueueableContext context){
        if(!test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }else{
            token = 'wetfgyuh56789fghj';
        }
        System.debug('token in queue class '+token);
        cancelSalesOrder(saleOrderCode, cancellationReason, token,lstSalesOrders,orderStatus);
        
        
    }
    
    //This REST API is used to cancel the sale order(s) in Uniware. This should be done before the order is dispatched by seller.
    public static void cancelSalesOrder(String saleOrderCode,String cancellationReason,String token,List<Opportunity> lstSalesOrders,String orderStatus){
        UnicommerceCancelSO__c cancelSettings = UnicommerceCancelSO__c.getValues('CancelAPI');
        cancelEndpoint = cancelSettings.CancelEndpoint__c;        
        system.debug(cancelEndpoint);
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setMethod('POST');
            req.setEndpoint(cancelEndpoint);            
            String reqBody = '{'+
                '"saleOrderCode": "'+saleOrderCode+'",'+
                '"cancellationReason": "'+cancellationReason+'"'+
                '}';
            req.setBody(reqBody);
            System.debug(reqBody);
            HttpResponse response = new HttpResponse();
            if(!test.isRunningTest()){
                response = http.send(req);
            }else{
                response.setStatusCode(200);
                response.setBody('{"successful":true,"message":"ABCDEFGHI","errors":[],"warnings":[],"saleOrderDetailDTO":{"code":"sdasdasd"}}');
            }
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() == 200){
                System.debug(response);
                if(mapResponse.get('successful') == true){
                    if(orderStatus != 'OrderRejected'){
           				 System.enqueueJob(new UnicommerceSalesOrderUtility(lstSalesOrders)); 
        			}
                    System.debug('Response message'+mapResponse.get('message'));
                }else{
                    System.debug(mapResponse.get('message'));
                    Map<String,Object> mapError = (Map<String,Object>)mapResponse.get('errors');
                    
                    Object lstObj = (Object)mapError;
                    Map<string,Object> mapObj = (Map<string,Object>)lstObj;
                    System.debug('Error '+mapObj.get('code'));
                    System.debug('Error '+mapObj.get('description'));
                    System.debug('Error '+mapObj.get('message'));
                }
            }
        }catch(Exception ex){
            System.debug('Exception '+ ex.getMessage());
            System.debug('Exception '+ ex.getLineNumber());
            System.debug('Exception '+ ex.getStackTraceString());
            
        }
    }
}