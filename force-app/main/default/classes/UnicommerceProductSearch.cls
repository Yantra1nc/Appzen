//  ** not in used yet
public class UnicommerceProductSearch {
    
    public static set<string> searchProducts(){
        Set<String> skuIds = new Set<String>();
        Map<String,Object> mapElements;
        Map<String,Object> mapProdSku;
        List<String> lstProd = new List<String>();
        Set<String> setIds = new Set<String>();
        
        //*** getting access token
        String token = UnicommerceAuthentication.getAuthenticationToken();
        system.debug('token::'+token);
        
        if(token !=null){
            
            try{
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setHeader('Authorization', 'Bearer ' + token);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('accept', 'application/json');
                String reqBody = '{ "keyword": "string","categoryCode": "default","getInventorySnapshot": true}';
                request.setBody(reqBody);        
                request.setEndpoint('https://demostaging.unicommerce.com/services/rest/v1/product/itemType/search');
                request.setMethod('POST'); 
                HttpResponse response = http.send(request);
                System.debug(response.getBody());
                if(response.getStatusCode() == 200){
                    Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    List<Object> lstObjects = (List<Object>)mapResponse.get('elements');            
                    for(Object obj:lstObjects){
                        mapElements = (Map<String,Object>)obj;                
                        //System.debug(mapElements.get('skuCode'));
                        skuIds.add((String)mapElements.get('skuCode'));
                    }                  
                    for(Product2 p:[Select Id, Material_Number__c from Product2]){
                        lstProd.add(p.Material_Number__c);
                    }
                    for(String s:skuIds){
                        if(!lstProd.contains(s)){
                            setIds.add(s);                   
                        }                    
                    }
                    UnicommerceProductDetailsBatch obj = new UnicommerceProductDetailsBatch(setIds);
                    System.debug('setIds size::'+setIds.size());                    
                }
            }catch(exception e){                
                system.debug('exception in searchProducts'+e.getMessage());
            }                                               
        }        
        return setIds;        
    }
}