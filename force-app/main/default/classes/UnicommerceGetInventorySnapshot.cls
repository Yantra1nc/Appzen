public class UnicommerceGetInventorySnapshot implements Schedulable{
    public static Set<String> setMaterialNo;
    public static String endPoint; 
    public static Map<String,Integer> mapProdId_Availability = new Map<String,Integer>();
    public static List<Product2> lstProducts;
    
    //Constructor which initialises the token, list of products and getting the endpoint from custom settings
    
    public void execute(SchedulableContext context){
        String token;
        UnicommerceInventory__c custSettings;
        custSettings = UnicommerceInventory__c.getValues('UCInventorySnapshot');
        endPoint = custSettings.UCInventorySnapshot__c;
        setMaterialNo = new Set<String>();
        lstProducts = [Select Id,Stock_Quantity__c,Material_Number__c from Product2 where Material_Number__c != null];
        
        for(Product2 p:lstProducts){
            if(p.Material_Number__c != null){
                setMaterialNo.add(p.Material_Number__c);
            }            
        }
        if(setMaterialNo.size() > 0 && endPoint != null){
            getInventorySnapshot(token,endPoint,setMaterialNo);
            //CronTrigger cron = [select ID,CronJobDetail.Name from CronTrigger where CronJobDetail.Name = 'Inventory Update'];
            //System.abortJob(cron.Id);
        }
        
    }    
    
    //Callout for inventory availability and update the stock field in products.
    
    @future(callout=true)
    public static void getInventorySnapshot(String token,String endPoint,Set<String> setMaterialNo){
        //get token here change added by Rahul T on 20/Jun/2022 to avoid calluot error
        if(!test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }else{
            token = 'wesdrfybjh4556yuv';
        }
        
        
        String buildSkuString = '';
        List<Product2> lstProdToUpdate = new List<Product2>();
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setHeader('facility','indocount-test');
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            Integer count = 0;
            for(String s:setMaterialNo){
                count++;
                if(count < setMaterialNo.size()){
                    buildSkuString = buildSkuString + '"'+s+'",';
                }else{
                    buildSkuString = buildSkuString + '"'+s+'"';
                }
                
            }
            System.debug(buildSkuString);
            String body = '{"itemTypeSKUs":['+buildSkuString+'],"updatedSinceInMinutes": "1440"}';
            //String body ='{"itemTypeSKUs":["FTR3300"],"updatedSinceInMinutes": "1440"}';
            req.setBody(body);
            HttpResponse res = http.send(req);
            System.debug(JSON.deserializeUntyped(res.getBody()));
            if(res.getStatusCode() == 200){
                Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                if((Boolean)mapResponse.get('successful') == true){
                    List<Object> lstsnapShots = (List<Object>)mapResponse.get('inventorySnapshots'); 
                    System.debug(lstsnapShots);
                    for(Object obj:lstsnapShots){
                        Map<String,Object> mapInventorySnapShots = (Map<String,Object>)obj; 
                        System.debug((String)mapInventorySnapShots.get('itemTypeSKU'));
                        System.debug((Integer)mapInventorySnapShots.get('inventory'));                        
                        mapProdId_Availability.put((String)mapInventorySnapShots.get('itemTypeSKU'),(Integer)mapInventorySnapShots.get('inventory'));
                    }
                    System.debug('keyset '+mapProdId_Availability.keySet());
                    for(Product2 p:[Select Id,Stock_Quantity__c,Material_Number__c from Product2 where Material_Number__c in:mapProdId_Availability.keySet()]){
                        p.Stock_Quantity__c = mapProdId_Availability.get(p.Material_Number__c);
                        system.debug('Products for updating'+p);
                        lstProdToUpdate.add(p);
                    }
                    update lstProdToUpdate; 
                }else{
                    List<Object> lstErrorObj = (List<Object>)mapResponse.get('errors');
                    for(Object errObj:lstErrorObj){
                        Map<String,Object> mapError = (Map<String,Object>)errObj;
                        System.debug('Code '+mapError.get('code'));
                        System.debug('Description '+mapError.get('description'));
                        System.debug('Message '+mapError.get('message'));                       
                    }
                }
                
            }
            
            
        }catch(CalloutException ex){
            System.debug('Exception '+ ex.getMessage());
        }        
    }
}