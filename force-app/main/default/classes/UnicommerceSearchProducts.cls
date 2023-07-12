global class UnicommerceSearchProducts implements Queueable,Database.AllowsCallouts {    
    
    global void execute(QueueableContext context){
        getSearchItems();
    }
    @future(callout=true)
    public static void getSearchItems(){
        String token;
        if(!Test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }
        else{
            token = 'acjascaisbciabsicbasibc';
        }
        Set<String> skuIds = new Set<String>();
        Map<String,Object> mapElements;
        Map<String,Object> mapProdSku;
        List<String> lstProd = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('accept', 'application/json');
        String reqBody = '{"productCode":"F51563"}';
        request.setBody(reqBody);        
        request.setEndpoint('https://demostaging.unicommerce.com/services/rest/v1/product/itemType/search');
        request.setMethod('POST'); 
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        if(response.getStatusCode() == 200){
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            List<Object> lstObjects = (List<Object>)mapResponse.get('elements');            
            for(Object obj:lstObjects){
                mapElements = (Map<String,Object>)obj;                
                System.debug(mapElements.get('skuCode'));
                skuIds.add((String)mapElements.get('skuCode'));
            }  
            Set<String> setIds = new Set<String>();
            for(Product2 p:[Select Id, Material_Number__c from Product2]){
                lstProd.add(p.Material_Number__c);
            }
            for(String s:skuIds){
                if(!lstProd.contains(s)){
                    setIds.add(s);                   
                }
            } 
            System.debug('setIds in Queueable::'+setIds.size());
            if(skuIds.size() > 0){
            }
        }
    }
}