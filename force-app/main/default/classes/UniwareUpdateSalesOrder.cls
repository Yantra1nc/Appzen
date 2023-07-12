public class UniwareUpdateSalesOrder implements Queueable,Database.AllowsCallouts{
    public static string updateEndpoint;
    public static string saleOrderCode;
   
    public UniwareUpdateSalesOrder(List<Opportunity> lstOpp){
        for(Opportunity opp:lstOpp){
            saleOrderCode = opp.Uniware_Internal_SO_No__c;
        }
    }
    public void execute(QueueableContext context){
        UniwareUpdateSO__c cancelSettings = UniwareUpdateSO__c.getValues('UniwareUpdateSO');
        updateEndpoint = cancelSettings.UpdateOrderEndpoint__c;
        String token;
        if(!Test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }else{
            token = 'nksndkanskdniweueu32';
        }
        updateSO(token,updateEndpoint,saleOrderCode);
        
    }
    
    public static void updateSO(String token,String endpoint,String saleOrderCode){
        Opportunity oppRec = [Select Id,Order_Type__c,Uniware_Internal_SO_No__c from Opportunity where Uniware_Internal_SO_No__c =:saleOrderCode limit 1];
        System.debug(updateEndpoint);
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setMethod('POST');
            req.setEndpoint(updateEndpoint);            
            String reqBody = '{'+
   							'"saleOrderCode":'+saleOrderCode+','+   							
       						'"customFieldValues": ['+
                              '{'+
                                 '"name": "ICIL_ORDER_TYPE",'+
                                 '"value": "Approved"'+
                			  '}'+
                 			  '{'+
                                 '"name": "PO_Number",'+ // needs to be changed when migrating
                                 '"value": "'+oppRec.Order_Type__c+'"'+
                			  '}'+
   							']'+
							'}';
            req.setBody(reqBody);
            System.debug(reqBody);
            HttpResponse response = http.send(req);
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() == 200){
                if(mapResponse.get('successful') == true){
                    System.debug('Response message'+mapResponse.get('message'));
                }else{
                    Map<String,Object> mapError = (Map<String,Object>)mapResponse.get('errors');
                    System.debug('Error '+mapError.get('code'));
                    System.debug('Error '+mapError.get('description'));
                    System.debug('Error '+mapError.get('message'));
                }
            }
        }catch(Exception ex){
            System.debug('Exception '+ ex.getMessage());
        }
    }
}