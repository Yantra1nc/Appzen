global class UnicommerceProductDetailsBatch implements Database.Batchable<string>,Schedulable, Database.Stateful,Database.AllowsCallouts {
    public final static string ENDPOINT = 'https://demostaging.unicommerce.com/services/rest/v1/catalog/itemType/get';    
    list<String> skusLst = new list<String>();
    List<Product2> lstProds = new List<Product2>();
    List<Product2> lstProdsUpdate = new List<Product2>();
    List<String> lstProd2 = new List<String>();
    Map<String,Product2> prodMap = new Map<String,Product2>();
    string Sectoken;    
    public void execute(SchedulableContext context){
        database.executeBatch(new UnicommerceProductDetailsBatch(this.Sectoken,this.skusLst),80);
    }
    
    global UnicommerceProductDetailsBatch(string token,List<String> lstIds) {
        this.skusLst = lstIds;
        this.Sectoken = token;
        system.debug('frombatchConstructor ::'+skusLst);        
        System.debug('List removed '+skusLst);
        for(Product2 p:[Select Id, Material_Number__c from Product2]){
            lstProd2.add(p.Material_Number__c);
            prodMap.put(p.Material_Number__c, p);
        }
    } 
    
    global Iterable<string> start(Database.BatchableContext BC) {  
        system.debug('in start method::'+skusLst.size());
        return new List<String>(skusLst);
    }
    
    global void execute(Database.BatchableContext BC, List<string> skusLst) {
        system.debug('in execute method::'+skusLst.size());        
        try{
            
            if(skusLst.size() > 0){
                for (string sku :skusLst){
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setHeader('Authorization', 'Bearer ' + Sectoken);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('accept', 'application/json');
                    String reqBody = '{"skuCode": '+'"'+sku+'"}';
                    request.setBody(reqBody);        
                    request.setEndpoint(ENDPOINT);
                    request.setMethod('POST');                        
                    HttpResponse response = http.send(request);
                    //System.debug(response.getBody());
                    Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String,Object> mapProdDetails = (Map<String,Object>)mapResponse.get('itemTypeDTO');
                    
                    //Mapping of the response with the product object  
                    //
                    if(lstProd2.contains((String)mapProdDetails.get('skuCode'))){
                        for(Product2 prod:prodMap.values()){
                            if(prod.Material_Number__c == (String)mapProdDetails.get('skuCode')){
                                prod.Name = (String)mapProdDetails.get('name');
                                prod.Material_Number__c = (String)mapProdDetails.get('skuCode');
                                prod.Description = (String)mapProdDetails.get('description');
                                //prod.Color__c = (String)mapProdDetails.get('color');
                                //prod.Size__c = (String)mapProdDetails.get('size');
                                prod.Brand__c = (String)mapProdDetails.get('brand');                   
                                prod.HSN__c = Decimal.valueOf(Double.valueOf(mapProdDetails.get('hsnCode'))) ;
                                prod.Product_Image_Link__c = (String)mapProdDetails.get('imageUrl');
                                prod.Kurl_On_to_Retailer_Price__c =  Double.valueOf(mapProdDetails.get('costPrice'));
                                prod.EAN__c = (String)mapProdDetails.get('ean');
                                prod.Fabric_Composition__c = (String)mapProdDetails.get('FABRICCOMPOSITION');
                                prod.Filling__c  = (String)mapProdDetails.get('FILLING');
                                prod.Filling_GSM__c  = (String)mapProdDetails.get('FILLINGGSM');
                                prod.Finish_Type__c  = (String)mapProdDetails.get('FINISHTYPE');
                                prod.GSM__c  = (String)mapProdDetails.get('GSM');
                                prod.Print_Type__c  = (String)mapProdDetails.get('PRINTTYPE');
                                prod.PRINTED_SOLID__c  = (String)mapProdDetails.get('PRINTEDSOLID');
                                prod.Type__c  = (String)mapProdDetails.get('TYPE');
                                prod.TYPE_OF_PROCESS__c  = (String)mapProdDetails.get('TYPEOFPROCESS');
                                prod.Weave__c  = (String)mapProdDetails.get('WEAVE');
                                prod.Category__c = (String)mapProdDetails.get('CATEGORY');
                                prod.Design_Type__c = (String)mapProdDetails.get('DESIGNTYPE');
                                prod.Design_Num__c = (String)mapProdDetails.get('DESIGNNO');
                                lstProdsUpdate.add(prod);
                            }
                        }
                    }else{
                        Product2 product = new Product2();
                        product.Name = (String)mapProdDetails.get('name');
                        product.Material_Number__c = (String)mapProdDetails.get('skuCode');
                        product.Description = (String)mapProdDetails.get('description');
                        //product.Color__c = (String)mapProdDetails.get('color');
                        //product.Size__c = (String)mapProdDetails.get('size');
                        product.Brand__c = (String)mapProdDetails.get('brand'); 
                        if(mapProdDetails.get('hsnCode') != null){
                            product.HSN__c = Double.valueOf(mapProdDetails.get('hsnCode')) ;
                        }else{
                            product.HSN__c = null;
                        }
                        product.Product_Image_Link__c = (String)mapProdDetails.get('imageUrl');
                        product.Kurl_On_to_Retailer_Price__c =  Double.valueOf(mapProdDetails.get('costPrice'));
                        product.EAN__c = (String)mapProdDetails.get('ean');
                        product.Fabric_Composition__c = (String)mapProdDetails.get('FABRICCOMPOSITION');
                        product.Filling__c  = (String)mapProdDetails.get('FILLING');
                        product.Filling_GSM__c  = (String)mapProdDetails.get('FILLINGGSM');
                        product.Finish_Type__c  = (String)mapProdDetails.get('FINISHTYPE');
                        product.GSM__c  = (String)mapProdDetails.get('GSM');
                        product.Print_Type__c  = (String)mapProdDetails.get('PRINTTYPE');
                        product.PRINTED_SOLID__c  = (String)mapProdDetails.get('PRINTEDSOLID');
                        product.Type__c  = (String)mapProdDetails.get('TYPE');
                        product.TYPE_OF_PROCESS__c  = (String)mapProdDetails.get('TYPEOFPROCESS');
                        product.Weave__c  = (String)mapProdDetails.get('WEAVE');
                        product.Category__c = (String)mapProdDetails.get('CATEGORY');
                        product.Design_Type__c = (String)mapProdDetails.get('DESIGNTYPE');
                        product.Design_Num__c = (String)mapProdDetails.get('DESIGNNO');
                        lstProds.add(product);
                        System.debug('Product Name inserted '+(String)mapProdDetails.get('name')); 
                    }                  
                    
                    
                }
            }
            List<Pricebook2> lstPb = [select Id from Pricebook2];
            List<PricebookEntry> lstPbeToInsert = new List<PricebookEntry>(); 
            
            if(lstProds.size() > 0){
                Database.SaveResult[] srList = Database.insert(lstProds,false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        system.debug('lstProds in SaveResult::'+sr);
                        for(Pricebook2 pb:lstPb){
                            PricebookEntry pbe = new PricebookEntry();
                            pbe.Product2Id = sr.getId();
                            pbe.Pricebook2Id = pb.Id;
                            lstPbeToInsert.add(pbe); 
                        }                    
                    }else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            if(lstProdsUpdate.size() > 0){
                Database.update(lstProdsUpdate, false) ;
            }
        }catch(exception e){
            system.debug('exceptionInBatchExecuteMethod::'+e.getMessage()+' '+e.getLineNumber());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('List to insert size in finish '+lstProds.size());
        System.debug('List to update size in finish '+lstProdsUpdate.size());
      
        
    }
}