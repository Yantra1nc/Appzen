public class GetSalesOrder{  
    
	public static string getSOEndpoint;  
    public String saleOrderCode;
    public String token;
        
    //This REST API is used to fetch sale order details from Uniware using sale order code and facility code (optional).   
    public static String getSalesOrder(String saleOrderCode,String token){
       	UnicommerceGetSO__c getSoSettings = UnicommerceGetSO__c.getValues('GetSalesOrderApi');
        getSOEndpoint = getSoSettings.GetSOApi__c;
        String result;
        System.debug(getSOEndpoint);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setMethod('POST');
            req.setEndpoint(getSOEndpoint);
            System.debug(getSOEndpoint);
            String reqBody = '{'+
                '"code": "'+saleOrderCode+'"'+               
                '}';
            req.setBody(reqBody);
            HttpResponse response = http.send(req);
            System.debug(response.getBody());
            try{
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() == 200){
                if(mapResponse.get('successful') == true){
                    System.debug('Response message'+mapResponse.get('saleOrderDTO'));
                    Map<String,Object> mapDTO = (Map<String,Object>)mapResponse.get('saleOrderDTO');
                    System.debug(mapDTO.get('shippingPackages'));
                    List<Object> lstObj = (List<Object>)mapDTO.get('shippingPackages');
                    List<String> lstInvCode = new List<String>();
                    for(Object obj:lstObj){
                        Map<String,Object> mapObj = (Map<String,Object>)obj;
                        System.debug(mapObj.get('invoiceCode'));
                        lstInvCode.add((String)mapObj.get('invoiceCode'));
                         if(mapObj.get('invoiceCode') != null){
                            result = 'Error';
                        }else if(mapObj.get('invoiceCode') == null){
                            result = 'Success';
                        }
                    }
                    
                   
                    
                }else{
                    Map<String,Object> mapError = (Map<String,Object>)mapResponse.get('errors');
                    System.debug('Error '+mapError.get('code'));
                    System.debug('Error '+mapError.get('description'));
                    System.debug('Error '+mapError.get('message'));
                }
            }
        }catch(Exception ex){
            System.debug('Exception '+ ex.getMessage());
            System.debug('Exception '+ ex.getLineNumber());
            System.debug('Exception '+ ex.getStackTraceString());
            result = 'Error';
            throw new AuraHandledException(ex.getMessage());

        }
        return result;
    }
    
}