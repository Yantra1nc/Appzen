global class UnicommerceProductDetails implements Queueable,Database.AllowsCallouts{
    public final static string ENDPOINT = 'https://demostaging.unicommerce.com/services/rest/v1/catalog/itemType/get';
    public Set<String> setSkuCodes;
    //Constructor
    public UnicommerceProductDetails(Set<String> skuCodes){
        setSkuCodes = skuCodes;
        System.debug(setSkuCodes.size());
    } 
    
    global void execute(QueueableContext context){
        String token;// = UnicommerceAuthentication.getAuthenticationToken();
        if(!Test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }
        else{
            token = '987tdcfhjkmnbhbfygjh';
        }
        if(token != null){
            getProductDetails(token,setSkuCodes);
        }
        
    }
    
    //Get the product details based on SKU code.    
    public static void getProductDetails(String token,Set<String> skuCodes){
        List<Product2> lstProds = new List<Product2>();
        Integer count = 0;
        try{
            if(token != null && skuCodes.size() > 0){                
                for(String sku:skuCodes){
                    count++;
                    if(count == 100){
                       break; 
                    }
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setHeader('Authorization', 'Bearer ' + token);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('accept', 'application/json');
                    String reqBody = '{"skuCode": '+'"'+sku+'"}';
                    request.setBody(reqBody);        
                    request.setEndpoint(ENDPOINT);
                    request.setMethod('POST'); 
                    HttpResponse response = http.send(request);
                    Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String,Object> mapProdDetails = (Map<String,Object>)mapResponse.get('itemTypeDTO');
                   
                    //Mapping of the response with the product object                    
                    Product2 product = new Product2();
                    product.Name = (String)mapProdDetails.get('name');
                    product.Material_Number__c = (String)mapProdDetails.get('skuCode');
                    product.Description = (String)mapProdDetails.get('description');
                                      product.Product_Image_Link__c = (String)mapProdDetails.get('imageUrl');
                    product.Kurl_On_to_Retailer_Price__c =  Double.valueOf(mapProdDetails.get('costPrice'));
                    product.EAN__c = (String)mapProdDetails.get('ean');
                    lstProds.add(product);
					System.debug('Product Name '+(String)mapProdDetails.get('name'));                    
                }
                System.debug(lstProds[0]);                
                insert lstProds[0];               
                        }
            
        }
        catch(CalloutException e){
            System.debug('Exception'+e.getMessage());
        }
        
    }
}