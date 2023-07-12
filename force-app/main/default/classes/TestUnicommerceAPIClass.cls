public class TestUnicommerceAPIClass {    
    
    @future (callout = true)
    @TestVisible
    public static void getAccessToken(){
        String endpoint;
        String accessToken;
        try {                  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            endpoint = 'https://demostaging.unicommerce.com/oauth/token?grant_type=password&client_id=my-trusted-client&username=sahil.sharma@unicommerce.com&password=sahuni';
            
            //req.setHeader('Authorization', 'bearer 12c12cb3-25a6-4226-9597-546d7ec5401a');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setCompressed(true);
            
            if (!Test.isRunningTest()) {      
                res = http.send(req);
                String sJson = res.getBody();
                
                System.debug('Str:' + sJson);
                //     opp.Response_Received__c = sJson;
                accessToken = parseResponse(sJson);
                System.debug('Token =' + accessToken);
                           
            }             
        } catch (Exception e) {         
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
            //      opp.Error_Message__c = e.getMessage();           
        } finally {
            
            //return accessToken;
        }
    }
    private static String parseResponse(String jsonInput) {
        String accessToken;
        JSONParser parser = JSON.createParser(jsonInput);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'access_token' ) {
                
                parser.nextToken();
                
                String oppName = parser.getText();
                accessToken = oppName;                  
            }
        }
        return accessToken;
    } 
}