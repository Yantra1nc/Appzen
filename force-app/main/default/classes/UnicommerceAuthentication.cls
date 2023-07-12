/** 
Class Name : UnicommerceAuthentication 
Description : Class which is used to get the token code from Unicommerce 
Created Date : 27/10/2021
Last Modified Date : 24/05/2022
Author: Rajiv
**/

public class UnicommerceAuthentication {
    public static Map<String,Object> mapResponse;
    private static string END_POINT;   
    //private final static string END_POINT = 'callout:Unicommerce/oauth/token?grant_type=password&client_id=my-trusted-client&username={0}&password={1}';
    
    //Method to get the authentication token from Unicommerce
    
    public static String getAuthenticationToken(){        
        try{
            UnicommerceAuthentication__c custSettings = UnicommerceAuthentication__c.getValues('AuthEndpointUrl');
            END_POINT  = custSettings.UnicommerceAuthEndpoint__c;
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('callout:Unicommerce/oauth/token?grant_type=password&client_id=my-trusted-client&username='+'{!$Credential.Username}'+'&password='+'{!$Credential.Password}');
            req.setEndpoint(END_POINT);            
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(req.getEndpoint());
            if(res.getStatusCode() == 200){
                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                System.debug(mapResponse.get('access_token'));
            }
        }catch(CalloutException e){
            System.debug('Exception'+e.getMessage());
        }
        return (String)mapResponse.get('access_token'); 
    }
    
    
    
}