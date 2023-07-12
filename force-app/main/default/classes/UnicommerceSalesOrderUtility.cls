/** 
Class Name : UnicommerceSalesOrder 
Description : Class which creates sales order to unicommerce,cancel and get salesorder from unicommerce 
Created Date : 27/10/2021
Last Modified Date : 24/05/2022
Author: Rajiv

**/

public class UnicommerceSalesOrderUtility implements Queueable,Database.AllowsCallouts{
    
    public static Map<Id,Opportunity> mapSalesOrder = new Map<Id,Opportunity>();
    public static Map<Opportunity,List<OpportunityLineItem>> mapOliWithOpp;
    public static String ENDPOINT;
    public static String cancelEndpoint;
    public static String getSOEndpoint;
    public static Map<String,Object> mapResponse;
    public String token;
    public List<Opportunity> lstSalesOrders = new List<Opportunity>();
    
    public UnicommerceSalesOrderUtility(){
        UnicommerceCreateSO__c custSettings = UnicommerceCreateSO__c.getValues('CreateSO');
        ENDPOINT = custSettings.CreateOrder__c;
        
        UnicommerceGetSO__c getSoSettings = UnicommerceGetSO__c.getValues('GetSalesOrderApi');
        getSOEndpoint = getSoSettings.GetSOApi__c;
        System.debug(getSOEndpoint);
        
    }
    
    public UnicommerceSalesOrderUtility(List<Opportunity> lstSalesOrders){
        this.lstSalesOrders = lstSalesOrders;
    }
    
    public void execute(QueueableContext context){
        if(!test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }else{
            token = 'wdqwd32ed23e23ed';
        }
        System.debug('token in queue class '+token);
        createSalesOrders(lstSalesOrders, token);
    }
    
    // This method create sales order in Unicommerce from Salesforce
    public static void createSalesOrders(List<Opportunity> lstSalesOrders,String token){
        String reqBody = '';  
        System.debug('SalesOrders '+lstSalesOrders);
        UnicommerceCreateSO__c custSettings = UnicommerceCreateSO__c.getValues('CreateSO');
        ENDPOINT = custSettings.CreateOrder__c;
        try{
            if(lstSalesOrders.size() > 0){
                
                for(Opportunity opp:lstSalesOrders){
                    mapSalesOrder.put(opp.Id,opp);
                }
            }
            System.debug(mapSalesOrder);
            List<OpportunityLineItem> lstOli = new List<OpportunityLineItem>();          
            Set<Id> setIds = new Set<Id>();
            Map<Id,OpportunityLineItem> mapLineItems = new Map<Id,OpportunityLineItem>([select Id,MU_Distributor_Margin__c,MD_Discount_Term__c,MD_Distributor_Margin__c,Item_Status__c,Indo_Count_to_Kurl_On_Price__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,ZDC2__c,Additional_Discount__c,OpportunityId,Final_Order_Value_after_GST__c,Total_Final_Order_Value_with_GST__c,Final_Order_Value_Ex_GST__c,Name,Quantity,Product2.Material_Number__c,UnitPrice from OpportunityLineItem where OpportunityId in:mapSalesOrder.keySet()]);
            System.debug(mapLineItems);
            List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            Set<ID>productIds = new Set<ID>();
            Map<Id,Opportunity>oppMap = new Map<Id,Opportunity>();
            
            for(Opportunity obj:lstSalesOrders){
                oppMap.put(obj.Id,obj);
                
                for(OpportunityLineItem oli:mapLineItems.values()){
                    if(obj.Id == oli.OpportunityId){
                        lstOli.add(oli);
                        productIds.add(oli.Product2Id);
                        System.debug('Oli '+oli);
                    } 
                    setIds.add(obj.Id);
                } 
                Map<Id,Product2>productMap = new Map<Id,Product2>();
                
                for(Product2 p : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) from Product2 where Id IN:productIds and IsActive = True AND Name != null]){
                    productMap.put(p.Id,p);
                }
                
                
                List<SalesOrderWrapper.SaleOrderItems> saleOrderItems = constructRequestBodyforOli(lstOli,productMap,oppMap);
                System.debug(saleOrderItems);                
                Account acc = [Select Id,Name,Customer_Type__c,Distrbution_Channel__c,
                               Phone,Service_Tax_Number__c,CST_Number__c,
                               BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode,ShippingCity,ShippingStreet,
                               ShippingState,ShippingCountry,ShippingPostalCode,Customer_Code_SOP__c,BillingAddress,ShippingAddress,Customer_Code__c from Account where Id=:obj.AccountId];
                
                Address addr = acc.BillingAddress;
                System.debug('Address obj '+addr);
                String acctStreet = acc.BillingStreet != null ? acc.BillingStreet : '';
                acctStreet.replaceAll('\n',' ');
                String acctCity = acc.BillingCity != null ? acc.BillingCity : '';
                String acctState = acc.BillingState != null ? acc.BillingState : '';
                String acctCountry = acc.BillingCountry != null ? acc.BillingCountry : '';
                String acctZip = acc.BillingPostalCode != null ? acc.BillingPostalCode : ''; 
                
                Address shippingAddress = acc.ShippingAddress;
                String shStreet = obj.Shipping_Street__c;
                shStreet.replaceAll('\n',' ');
                String shCity = obj.Shipping_City__c != null ? obj.Shipping_City__c  : '';
                String shState = obj.Shipping_State_Province__c != null ? obj.Shipping_State_Province__c : '';
                String shCountry = obj.Shipping_Country__c != null ? obj.Shipping_Country__c : '';
                String shZip = obj.Shipping_Zip_Postal_Code__c != null ? obj.Shipping_Zip_Postal_Code__c : ''; 
                String SHRef = obj.Customer_Code_SHP__c != null ? obj.Customer_Code_SHP__c : '60002';
                String SOPref = obj.Customer_Code_SOP__c != null ? obj.Customer_Code_SOP__c : '60003';
                
                SalesOrderWrapper reqObject = new SalesOrderWrapper();
                
                SalesOrderWrapper.SaleOrder sOrder = new SalesOrderWrapper.SaleOrder();
                //create order here
                //sOrder.thirdPartyShipping = false;
                
                if(acc.Customer_Type__c != null){
                    sOrder.channel = acc.Customer_Type__c+'_'+acc.Distrbution_Channel__c;
                }else{
                    sOrder.channel = 'CUSTOM';
                }
                
                sOrder.cashOnDelivery = false;
                sOrder.customerName = acc.Customer_Code_SOP__c+'_'+acc.Name;
                sOrder.customerCode = obj.Customer_Code__c;
                reqObject.saleOrder = sOrder;
                if(saleOrderItems != null && !saleOrderItems.isEMpty()){
                    sOrder.saleOrderItems = saleOrderItems;
                }
                List<SalesOrderWrapper.Addresses>addressList = new List<SalesOrderWrapper.Addresses>();               
                //billing address
                SalesOrderWrapper.Addresses billingAddrObj = new SalesOrderWrapper.Addresses();
                billingAddrObj.id = SOPref;//'60002';
                billingAddrObj.name = acc.Name;
                if(String.isNotBlank(shStreet)){
                    billingAddrObj.addressLine1 = shStreet;
                }
                if(String.isNotBlank(shCity)){
                    billingAddrObj.city = shCity;
                }
                if(String.isNotBlank(shState)){
                    billingAddrObj.state = shState;
                }
                if(String.isNotBlank(shCountry)){
                    billingAddrObj.country = shCountry;
                }
                if(shZip != null && String.isNotBlank(shZip)){
                    billingAddrObj.pincode = shZip;
                }
                if(acc.Phone != null && String.isNotBlank(acc.Phone)){
                    billingAddrObj.phone = acc.Phone;
                }
                addressList.add(billingAddrObj);
                
                //shipping address
                SalesOrderWrapper.Addresses shippingAddrObj = new SalesOrderWrapper.Addresses();
                shippingAddrObj.id = SHref;//'60002';
                shippingAddrObj.name = acc.Name;
                if(String.isNotBlank(acctStreet)){
                    shippingAddrObj.addressLine1 = acctStreet;
                }
                if(String.isNotBlank(acctCity)){
                    shippingAddrObj.city = acctCity;
                }
                if(String.isNotBlank(acctState)){
                    shippingAddrObj.state = acctState;
                }
                if(String.isNotBlank(acctCountry)){
                    shippingAddrObj.country = acctCountry;
                }
                if(acctZip != null && String.isNotBlank(acctZip)){
                    shippingAddrObj.pincode = acctZip;
                }
                if(acc.Phone != null && String.isNotBlank(acc.Phone)){
                    shippingAddrObj.phone = acc.Phone;
                }
                addressList.add(shippingAddrObj);
                
                sOrder.addresses = addressList;
                
                //set address reference here
                SalesOrderWrapper.BillingAddress billingAddr = new SalesOrderWrapper.BillingAddress();
                billingAddr.referenceId = SOPref;//'60002';
                sOrder.billingAddress = billingAddr;
                SalesOrderWrapper.BillingAddress shippingAddr = new SalesOrderWrapper.BillingAddress();
                shippingAddr.referenceId = SHref;//'60002';
                sOrder.shippingAddress = shippingAddr;
                
                List<SalesOrderWrapper.CustomFieldValues>customFldValues = new List<SalesOrderWrapper.CustomFieldValues>();
                SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                field1.name ='SHIPTOPARTY';
                field1.value = SHref;
                customFldValues.add(field1);
                
                SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                field2.name ='SOLDTOPARTY';
                field2.value = SOPref;
                customFldValues.add(field2);
                
                SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                field4.name ='ORDERTYPE';
                field4.value = obj.Order_Type__c;
                if(obj.Order_Type__c != null){
                    customFldValues.add(field4);
                }
                
                SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                field5.name ='SFORDERSTATUS';
                field5.value = obj.StageName;
                customFldValues.add(field5);
                
                if(obj.Uniware_Internal_SO_No__c == null){
                    System.debug('uid null');
                    sOrder.code = obj.Sales_Order_No__c;
                    sOrder.displayOrderCode = obj.Sales_Order_No__c;
                    SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                    field3.name ='HEADERSTATUS';
                    field3.value = obj.Header_Status__c;
                    if(obj.Header_Status__c != null){
                        customFldValues.add(field3);
                    }
                    
                }
                else if(!obj.Uniware_Internal_SO_No__c.containsAny('_') && obj.Uniware_Internal_SO_No__c != null){
                    System.debug('uid not null and not contains _');
                    String uniwareCodeToUpdate = obj.Sales_Order_No__c;
                    uniwareCodeToUpdate = uniwareCodeToUpdate+'_1'; 
                    
                    sOrder.code = uniwareCodeToUpdate;
                    sOrder.displayOrderCode = uniwareCodeToUpdate;
                    
                }
                else{
                    System.debug('else ');
                    String uniwareCodeToUpdate = obj.Uniware_Internal_SO_No__c;
                    System.debug(uniwareCodeToUpdate);
                    Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
                    System.debug(version);
                    String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
                    System.debug(beforeCode);
                    version = version+1;
                    uniwareCodeToUpdate = beforeCode+'_'+version;                   
                    
                    sOrder.code = uniwareCodeToUpdate;
                    sOrder.displayOrderCode = uniwareCodeToUpdate;
                    
                }   
                
                sOrder.customFieldValues = customFldValues;
                transient String requBody = JSON.serialize(reqObject);
                
                //lstOppToUpdate.add(callOutSalesOrderCreation(requBody,token,obj));            
                
                //call here
                //       try{
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+token);
                req.setHeader('facility','indocount-test');
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setEndpoint(ENDPOINT);
                req.setBody(requBody);
                // transient HttpResponse res = http.send(req); 
                //   System.debug('******* RESP  '+res);
                //  System.debug('********* RESP body '+res.getBody());
                
                //mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                
                
                
                //  if(res.getStatusCode() == 200){
                /*   if(mapResponse.get('successful') == true){
System.debug('JobCode '+mapResponse.get('saleOrderDetailDTO'));                    
mapCode = (Map<String,Object>)mapResponse.get('saleOrderDetailDTO');
System.debug(mapCode.get('code'));
String uniwareCodeToUpdate;
String uniwareCode = '';
if(mapCode != null && mapCode.containsKey('code')){
uniwareCode = String.valueOf(mapCode.get('code'));
}
opp.Success_Error_log__c = '<b>SUCCESS</b><br/>Order created with '+uniwareCode;

//update SO code here
if(opp.Uniware_Internal_SO_No__c == null || opp.Uniware_Internal_SO_No__c == ''){
//cancel Order here
//cancelSalesOrder(opp.Sales_Order_No__c,uniwareCode+' Order created');

opp.Uniware_Internal_SO_No__c = uniwareCode;  
}else{
//cancel Order here
cancelSalesOrder(opp.Uniware_Internal_SO_No__c,uniwareCode+' Order created');

uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c;
System.debug(opp.Uniware_Internal_SO_No__c);
if(String.isNotBlank(uniwareCodeToUpdate) && uniwareCodeToUpdate.contains('_')){
Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
version = version+1;                    
uniwareCodeToUpdate = beforeCode+'_'+version;
}else{
uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c+'_1';
}
opp.Uniware_Internal_SO_No__c = uniwareCodeToUpdate; 
}



}else{
if(mapResponse.containsKey('errors') ){
opp.Success_Error_log__c = '<b>Order creation failed...</b><br/>';
opp.Success_Error_log__c += String.valueOf( mapResponse.get('errors'));
}
}
*/
                String res='';
                
                System.debug('HEAP SIZE '+Limits.getHeapSize());
                if(Limits.getHeapSize() > 275000) {
                    res = '{"successful":true,"message":null,"errors":[],"warnings":null,"saleOrderDTO":{"code":"'+sOrder.code+'","displayOrderCode":"'+sOrder.code+'","channel":"KURLON_68"}}';
                }
                try{
                    res = new Http().send(req).getBody().trim();
                }catch(Exception e){
                    System.debug('ERROR '+e.getMessage()+' '+e.getLineNumber());
                }
                
                if(res.containsIgnoreCase('errors')){
                    String errStr = res.substringBefore('warnings');
                    errStr = errStr.substringAfter('errors":');
                    obj.Success_Error_log__c = '<b>Order creation failed...</b><br/>';
                    obj.Success_Error_log__c += String.valueOf(errStr);
                }
                
               
                                
                if((res.containsIgnoreCase('"successful":true') || res.containsIgnoreCase('"successful": true')) && res.containsIgnoreCase('code') && res.containsIgnoreCase('displayOrderCode')){
                    System.debug('In order creation... ');
                    String uniwareCodeToUpdate;
                    String uniwareCode = '';    
                    uniwareCode = res.substringBefore('displayOrderCode');
                    uniwareCode = uniwareCode.substringAfter('code');
                    uniwareCode = uniwareCode.remove(',');
                    uniwareCode = uniwareCode.remove('"');
                    uniwareCode = uniwareCode.remove(':');
                    
                    obj.Success_Error_log__c = '<b>SUCCESS</b><br/>Order created with '+uniwareCode;
                    
                    //update SO code here
                    if(obj.Uniware_Internal_SO_No__c == null || obj.Uniware_Internal_SO_No__c == ''){
                        //cancel Order here
                        //cancelSalesOrder(obj.Sales_Order_No__c,uniwareCode+' Order created');
                        System.debug('in Order New...');
                        
                        obj.Uniware_Internal_SO_No__c = uniwareCode;  
                    }else{
                        System.debug('in Order Update...');
                        //cancel Order here
                        cancelSalesOrder(obj.Uniware_Internal_SO_No__c,uniwareCode+' Order created');
                        
                        uniwareCodeToUpdate = obj.Uniware_Internal_SO_No__c;
                        System.debug(obj.Uniware_Internal_SO_No__c);
                        if(String.isNotBlank(uniwareCodeToUpdate) && uniwareCodeToUpdate.contains('_')){
                            Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
                            String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
                            version = version+1;                    
                            uniwareCodeToUpdate = beforeCode+'_'+version;
                        }else{
                            uniwareCodeToUpdate = obj.Uniware_Internal_SO_No__c+'_1';
                        }
                        obj.Uniware_Internal_SO_No__c = uniwareCodeToUpdate; 
                    }
                    
                    
                }else if(res.containsIgnoreCase('errors')){
                    String errStr = res.substringBefore('warnings');
                    errStr = errStr.substringAfter('errors":');
                    obj.Success_Error_log__c = '<b>Order creation failed...</b><br/>';
                    obj.Success_Error_log__c += String.valueOf(errStr);
                }
                //   }
                lstOppToUpdate.add(obj);
                //   }catch(CalloutException ex){
                //      System.debug('Exception thrown '+ex.getMessage());
                // }
                
            }
            
            List<Opportunity> lstOp = [Select Id,Uniware_Internal_SO_No__c from Opportunity where Id in:setIds];
            for(Opportunity opp:lstOppToUpdate){
                
                //opp.StageName = 'Submitted for Approval';
                //update SO
                Approval.UnlockResult[] urList = Approval.unlock(lstOp, false);
                for(Approval.UnlockResult ur : urList) {
                    if (ur.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked opp with ID: ' + ur.getId());
                        update lstOppToUpdate;   
                        Approval.lock(lstOp,false);
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : ur.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Opp fields that affected this error: ' + err.getFields());
                        }
                    }
                }         
                //Approval.lock(lstOp,false);
            }
            
            
        }catch(CalloutException e){
            System.debug('Callout Exception '+e.getMessage());
            System.debug('Callout Exception '+e.getCause());
            System.debug('Callout Exception '+e.getStackTraceString());
            System.debug('Callout Exception '+e.getLineNumber());
        }
    }
    //SalesOrderWrapper
    public static List<SalesOrderWrapper.SaleOrderItems> constructRequestBodyforOli(List<OpportunityLineItem> lstOli,Map<ID,Product2>productMap,Map<ID,Opportunity>oppMap){
        List<SalesOrderWrapper.SaleOrderItems>orderLines = new List<SalesOrderWrapper.SaleOrderItems>();
        
        String reqBodyOli = '"saleOrderItems":[';
        String buildReq; 
        Integer count = 0;
        
        for(OpportunityLineItem oli:lstOli){ 
            
            Product2 p;
            if(productMap.containsKey(oli.Product2Id)){
                p = productMap.get(oli.Product2Id);
            }
            
            Price_Master__c pm;
            Double distChan = 0;
            
            if(oppMap.containsKey(oli.OpportunityId)){
                pm = DynamicDiscount.findPriceMaster(p,oppMap.get(oli.OpportunityId));
                if(oppMap.get(oli.OpportunityId).Distrbution_Channel__c != null){
                    distChan = Double.valueOf(oppMap.get(oli.OpportunityId).Distrbution_Channel__c);
                }
            }
            Decimal zrlgPercentage = getZRLG(pm,p,distChan);
            count++;
            if(/*oli.Quantity > 1000*/ false){
                Decimal quantity = oli.Quantity;
                Decimal rem = quantity/1000;
                Map<String,Object>dataMap = new Map<String,Object>();
                dataMap.put('oppRecord',oppMap.get(oli.OpportunityId));
                dataMap.put('OliRecord',oli);
                dataMap.put('qty',quantity/rem);
                dataMap.put('count',0);
                dataMap.put('lstOlisize',lstOli.size());
                dataMap.put('zrlgPercentage',String.valueOf(zrlgPercentage));
                //divide the quantity
                LineItemCreatorUtility.createFile(JSON.serialize(dataMap));
            }else{
                for(Integer i=1;i<=oli.Quantity;i++){
                    System.debug(i);
                    System.debug(count);
                    if(lstOli.size() == 1){
                        if(oli.Quantity == 1){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            fields.add(field6);
                            
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            fields.add(field7);
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            
                            //field4.value = String.valueOf(zrlgPercentage);
                            
                            
                            orderLines.add(line);
                            
                        }
                        else if(oli.Quantity > 1 && oli.Quantity != i){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            orderLines.add(line);
                            
                            
                        } 
                        else if(oli.Quantity == i){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            orderLines.add(line);
                            
                        }                    
                    }
                    else if(lstOli.size() > 1){
                        if(oli.Quantity == 1){
                            if(buildReq == null){
                                SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                                line.itemSku = oli.Product2.Material_Number__c;
                                line.shippingMethodCode = 'STD';
                                line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                                line.packetNumber = '1';
                                line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                line.prepaidAmount = '0';
                                line.discount = '0';
                                line.shippingCharges = '0';
                                
                                List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                                
                                SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                                field1.name = 'ITEMSTATUS';
                                field1.value = oli.Item_Status__c;
                                //fields.add(field1);
                                
                                SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                                field2.name = 'ZADCADDITIONALDISCOUNT';
                                field2.value = String.valueOf(oli.Additional_Discount__c);
                                fields.add(field2);
                                
                                SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                                field3.name = 'ZDC2DISCOUNT';
                                if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                    field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }else{
                                    field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }
                                fields.add(field3);
                                
                                SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                                field4.name = 'ZDMIDISTRIBUTORMARGIN';
                                if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                    field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                                }else{
                                    field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                                } 
                                //field4.value = String.valueOf(zrlgPercentage);
                                fields.add(field4);
                                
                                SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                                field5.name = 'ZMRPMRP';
                                field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                                fields.add(field5);
                                
                                SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                                field6.name = 'ZRLGRETAILERGST';
                                field6.value = String.valueOf(zrlgPercentage);
                                if(oli.MD_Retailer_GST__c != null){
                                    fields.add(field6);
                                }
                                SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                                field7.name = 'ZRMDRETAILERMARGIN';
                                field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                                if(oli.MD_Retailer_Margin__c != null){
                                    fields.add(field7);
                                }
                                if(fields != null && !fields.isEmpty()){
                                    line.customFieldValues = fields;
                                }
                                orderLines.add(line);
                                
                                
                            }
                            else if(buildReq != null){
                                if(count == lstOli.size()){
                                    
                                    SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                                    line.itemSku = oli.Product2.Material_Number__c;
                                    line.shippingMethodCode = 'STD';
                                    line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                                    line.packetNumber = '1';
                                    line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                    line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                    line.prepaidAmount = '0';
                                    line.discount = '0';
                                    line.shippingCharges = '0';
                                    
                                    List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                                    
                                    SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                                    field1.name = 'ITEMSTATUS';
                                    field1.value = oli.Item_Status__c;
                                    //fields.add(field1);
                                    
                                    SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                                    field2.name = 'ZADCADDITIONALDISCOUNT';
                                    field2.value = String.valueOf(oli.Additional_Discount__c);
                                    fields.add(field2);
                                    
                                    SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                                    field3.name = 'ZDC2DISCOUNT';
                                    if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                        field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                    }else{
                                        field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                    }
                                    fields.add(field3);
                                    
                                    SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                                    field4.name = 'ZDMIDISTRIBUTORMARGIN';
                                    if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                        field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                                    }else{
                                        field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                                    }
                                    //field4.value = String.valueOf(zrlgPercentage);
                                    fields.add(field4);
                                    
                                    SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                                    field5.name = 'ZMRPMRP';
                                    field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                                    fields.add(field5);
                                    
                                    SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                                    field6.name = 'ZRLGRETAILERGST';
                                    field6.value = String.valueOf(zrlgPercentage);
                                    if(oli.MD_Retailer_GST__c != null){
                                        fields.add(field6);
                                    }
                                    SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                                    field7.name = 'ZRMDRETAILERMARGIN';
                                    field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                                    if(oli.MD_Retailer_Margin__c != null){
                                        fields.add(field7);
                                    }
                                    if(fields != null && !fields.isEmpty()){
                                        line.customFieldValues = fields;
                                    }
                                    orderLines.add(line);
                                    
                                }
                                else{
                                    
                                    SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                                    line.itemSku = oli.Product2.Material_Number__c;
                                    line.shippingMethodCode = 'STD';
                                    line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                                    line.packetNumber = '1';
                                    line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                    line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                    line.prepaidAmount = '0';
                                    line.discount = '0';
                                    line.shippingCharges = '0';
                                    
                                    List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                                    
                                    SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                                    field1.name = 'ITEMSTATUS';
                                    field1.value = oli.Item_Status__c;
                                    //fields.add(field1);
                                    
                                    SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                                    field2.name = 'ZADCADDITIONALDISCOUNT';
                                    field2.value = String.valueOf(oli.Additional_Discount__c);
                                    fields.add(field2);
                                    
                                    SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                                    field3.name = 'ZDC2DISCOUNT';
                                    if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                        field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                    }else{
                                        field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                    }
                                    fields.add(field3);
                                    
                                    SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                                    field4.name = 'ZDMIDISTRIBUTORMARGIN';
                                    if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                        field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                                    }else{
                                        field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                                    }
                                    // field4.value = String.valueOf(zrlgPercentage);
                                    fields.add(field4);
                                    
                                    SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                                    field5.name = 'ZMRPMRP';
                                    field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                                    fields.add(field5);
                                    
                                    SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                                    field6.name = 'ZRLGRETAILERGST';
                                    field6.value = String.valueOf(zrlgPercentage);
                                    if(oli.MD_Retailer_GST__c != null){
                                        fields.add(field6);
                                    }
                                    SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                                    field7.name = 'ZRMDRETAILERMARGIN';
                                    field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                                    if(oli.MD_Retailer_Margin__c != null){
                                        fields.add(field7);
                                    }
                                    if(fields != null && fields.isEmpty()){
                                        line.customFieldValues = fields;
                                    }
                                    orderLines.add(line);
                                    
                                    
                                    
                                }                            
                            }                        
                        }
                        else if(oli.Quantity > 1 && oli.Quantity != i){
                            if(buildReq == null){
                                
                                SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                                line.itemSku = oli.Product2.Material_Number__c;
                                line.shippingMethodCode = 'STD';
                                line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                                line.packetNumber = '1';
                                line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                                line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                                line.prepaidAmount = '0';
                                line.discount = '0';
                                line.shippingCharges = '0';
                                
                                List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                                
                                SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                                field1.name = 'ITEMSTATUS';
                                field1.value = oli.Item_Status__c;
                                //fields.add(field1);
                                
                                SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                                field2.name = 'ZADCADDITIONALDISCOUNT';
                                field2.value = String.valueOf(oli.Additional_Discount__c);
                                fields.add(field2);
                                
                                SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                                field3.name = 'ZDC2DISCOUNT';
                                if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                    field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }else{
                                    field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }
                                fields.add(field3);
                                
                                SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                                field4.name = 'ZDMIDISTRIBUTORMARGIN';
                                if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                    field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                                }else{
                                    field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                                }
                                // field4.value = String.valueOf(zrlgPercentage);
                                fields.add(field4);
                                
                                SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                                field5.name = 'ZMRPMRP';
                                field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                                fields.add(field5);
                                
                                SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                                field6.name = 'ZRLGRETAILERGST';
                                field6.value = String.valueOf(zrlgPercentage);
                                if(oli.MD_Retailer_GST__c != null){
                                    fields.add(field6);
                                }
                                SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                                field7.name = 'ZRMDRETAILERMARGIN';
                                field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                                if(oli.MD_Retailer_Margin__c != null){
                                    fields.add(field7);
                                }
                                if(fields != null && !fields.isEmpty()){
                                    line.customFieldValues = fields;
                                }   
                                orderLines.add(line);
                                
                            }
                            else if(buildReq != null){
                                
                                SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                                line.itemSku = oli.Product2.Material_Number__c;
                                line.shippingMethodCode = 'STD';
                                line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                                line.packetNumber = '1';
                                line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                                line.prepaidAmount = '0';
                                line.discount = '0';
                                line.shippingCharges = '0';
                                
                                List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                                
                                SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                                field1.name = 'ITEMSTATUS';
                                field1.value = oli.Item_Status__c;
                                //fields.add(field1);
                                
                                SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                                field2.name = 'ZADCADDITIONALDISCOUNT';
                                field2.value = String.valueOf(oli.Additional_Discount__c);
                                fields.add(field2);
                                
                                SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                                field3.name = 'ZDC2DISCOUNT';
                                if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                    field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }else{
                                    field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                                }
                                fields.add(field3);
                                
                                SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                                field4.name = 'ZDMIDISTRIBUTORMARGIN';
                                if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                    field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                                }else{
                                    field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                                }
                                fields.add(field4);
                                
                                SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                                field5.name = 'ZMRPMRP';
                                field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                                fields.add(field5);
                                
                                SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                                field6.name = 'ZRLGRETAILERGST';
                                field6.value = String.valueOf(zrlgPercentage);
                                if(oli.MD_Retailer_GST__c != null){
                                    fields.add(field6);
                                }
                                SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                                field7.name = 'ZRMDRETAILERMARGIN';
                                field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                                if(oli.MD_Retailer_Margin__c != null){
                                    fields.add(field7);
                                }
                                
                                if(fields != null && !fields.isEmpty()){
                                    line.customFieldValues = fields;
                                }      
                                orderLines.add(line);
                                
                                
                            }                       
                        }
                        else if(oli.Quantity == i && count < lstOli.size()){
                            
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }      
                            orderLines.add(line);
                            
                        } 
                        else if(oli.Quantity == i && count == lstOli.size()){
                            
                            
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / oli.Quantity);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(oli.MD_Retailer_GST__c);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            orderLines.add(line);
                            
                        } 
                    }
                }
            }
        }
        
        reqBodyOli = reqBodyOli+buildreq+']';
        System.debug(reqBodyOli);
        return orderLines;
    }
    
    public static Opportunity callOutSalesOrderCreation(String reqBody,String token,Opportunity opp ){
        
        System.debug(ENDPOINT);
        System.debug('*******reqBody '+reqBody);
        System.debug(token);
        Map<String,Object> mapCode = new Map<String,Object>();
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setHeader('facility','indocount-test');
            req.setMethod('POST');
            req.setTimeout(12000);
            req.setEndpoint(ENDPOINT);
            req.setBody(reqBody);
            HttpResponse res = http.send(req); 
            System.debug('******* RESP  '+res);
            System.debug('********* RESP body '+res.getBody());
            
            
            
            
            if(res.getStatusCode() == 200){
                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('Request Payload Success ');
                if(mapResponse.get('successful') == true){
                    System.debug('JobCode '+mapResponse.get('saleOrderDTO'));                    
                    mapCode = (Map<String,Object>)mapResponse.get('saleOrderDTO');
                    String uniwareCodeToUpdate;
                    String uniwareCode = '';
                    if(mapCode != null && mapCode.containsKey('code')){
                        uniwareCode = String.valueOf(mapCode.get('code'));
                        
                    }
                    opp.Success_Error_log__c = '<b>SUCCESS</b><br/>Order created with '+uniwareCode;
                    
                    //update SO code here
                    if(opp.Uniware_Internal_SO_No__c == null || opp.Uniware_Internal_SO_No__c == ''){
                        //cancel Order here
                        //cancelSalesOrder(opp.Sales_Order_No__c,uniwareCode+' Order created');
                        
                        opp.Uniware_Internal_SO_No__c = uniwareCode;  
                    }else{
                        //cancel Order here
                        cancelSalesOrder(opp.Uniware_Internal_SO_No__c,uniwareCode+' Order created');
                        
                        uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c;
                        System.debug(opp.Uniware_Internal_SO_No__c);
                        if(String.isNotBlank(uniwareCodeToUpdate) && uniwareCodeToUpdate.contains('_')){
                            Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
                            String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
                            version = version+1;                    
                            uniwareCodeToUpdate = beforeCode+'_'+version;
                        }else{
                            uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c+'_1';
                        }
                        opp.Uniware_Internal_SO_No__c = uniwareCodeToUpdate; 
                    }
                    
                    
                    
                }else{
                    if(mapResponse.containsKey('errors') ){
                        opp.Success_Error_log__c = '<b>Order creation failed...</b><br/>';
                        opp.Success_Error_log__c += String.valueOf( mapResponse.get('errors'));
                    }
                }
                
                
                if(res.getBody().containsIgnoreCase('"successful": true')){
                    String uniwareCodeToUpdate;
                    String uniwareCode = '';    
                    uniwareCode = res.getBody().substringBefore('"code": "');
                    uniwareCode = uniwareCode.substringAfter('displayOrderCode');
                    opp.Success_Error_log__c = '<b>SUCCESS</b><br/>Order created with '+uniwareCode;
                    
                    //update SO code here
                    if(opp.Uniware_Internal_SO_No__c == null || opp.Uniware_Internal_SO_No__c == ''){
                        //cancel Order here
                        //cancelSalesOrder(opp.Sales_Order_No__c,uniwareCode+' Order created');
                        
                        opp.Uniware_Internal_SO_No__c = uniwareCode;  
                    }else{
                        //cancel Order here
                        cancelSalesOrder(opp.Uniware_Internal_SO_No__c,uniwareCode+' Order created');
                        
                        uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c;
                        System.debug(opp.Uniware_Internal_SO_No__c);
                        if(String.isNotBlank(uniwareCodeToUpdate) && uniwareCodeToUpdate.contains('_')){
                            Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
                            String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
                            version = version+1;                    
                            uniwareCodeToUpdate = beforeCode+'_'+version;
                        }else{
                            uniwareCodeToUpdate = opp.Uniware_Internal_SO_No__c+'_1';
                        }
                        opp.Uniware_Internal_SO_No__c = uniwareCodeToUpdate; 
                    }
                    
                    
                }else if(res.getBody().containsIgnoreCase('errors')){
                    String errStr = res.getBody().substringBefore('"warnings"');
                    errStr = res.getBody().substringBefore('errors": [');
                    opp.Success_Error_log__c = '<b>Order creation failed...</b><br/>';
                    opp.Success_Error_log__c += String.valueOf(errStr);
                }
            }
        }catch(CalloutException ex){
            System.debug('Exception thrown '+ex.getMessage());
        }
        return opp;
    }
    
    //This REST API is used to cancel the sale order(s) in Uniware. This should be done before the order is dispatched by seller.
    public static void cancelSalesOrder(String saleOrderCode,String cancellationReason){
        UnicommerceCancelSO__c cancelSettings = UnicommerceCancelSO__c.getValues('CancelAPI');
        cancelEndpoint = cancelSettings.CancelEndpoint__c;
        String token;
        if(!test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }else{
            token = 'tr776t7tggyff';
        }
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
    
    //This REST API is used to fetch sale order details from Uniware using sale order code and facility code (optional).
    public static void getSalesOrder(String saleOrderCode,String token){
        UnicommerceGetSO__c getSoSettings = UnicommerceGetSO__c.getValues('GetSalesOrderApi');
        getSOEndpoint = getSoSettings.GetSOApi__c;
        System.debug(getSOEndpoint);
        try{
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
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() == 200){
                if(mapResponse.get('successful') == true){
                    System.debug('Response message'+mapResponse.get('saleOrderDTO'));
                    Map<String,Object> mapDTO = (Map<String,Object>)mapResponse.get('saleOrderDTO');
                    System.debug(mapDTO.get('shippingPackages'));
                    
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
        }
    }
    
    
    //code generator
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    //get zrlg percentage
    public static Decimal getZRLG(Price_Master__c pm,Product2 p,Double channelNo){
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = p != null ? [Select Name,Distribution_No__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c] : new List<ZRLG__c>();
        System.debug('lstRLg' + lstRlg);
        System.debug(pm);
        System.debug(pm.Active__c);
        System.debug(pm.Activated_End_Date__c > Datetime.now());
        if (pm.Active__c == true && pm.Activated_End_Date__c > Datetime.now()) {
            System.debug('Inside condition ');
            if (pm.MD_Retailer_Margin__c > 0 && pm.MU_Retailer_Margin__c == 0) {
                pm.MD_Retailer_Margin__c = pm.MD_Retailer_Margin__c;
            }else if(pm.MU_Retailer_Margin__c > 0 && pm.MD_Retailer_Margin__c == 0){
                pm.MD_Retailer_Margin__c = pm.MU_Retailer_Margin__c;
            }
            if (pm.MD_Distributor_Margin__c > 0 && pm.MU_Distributor_Margin__c == 0) {
                pm.MD_Distributor_Margin__c = pm.MD_Distributor_Margin__c;
            }else if(pm.MU_Distributor_Margin__c > 0 && pm.MD_Distributor_Margin__c == 0){
                pm.MD_Distributor_Margin__c = pm.MU_Distributor_Margin__c;
            }
            if (pm.MD_Retailer_GST__c > 0 && pm.MU_Retailer_GST__c == 0) {
                pm.MD_Retailer_GST__c = pm.MD_Retailer_GST__c;
            }else if(pm.MU_Retailer_GST__c > 0 && pm.MD_Retailer_GST__c == 0){
                pm.MD_Retailer_GST__c = pm.MU_Retailer_GST__c;
            }
            System.debug('Unit price '+p.PricebookEntries[0].UnitPrice);
            Decimal unitPrice = (Decimal)p.PricebookEntries[0].UnitPrice;
            Decimal absDiscPrice = unitPrice - (unitPrice * (pm.MD_Disc_Term__c/100)); 
            System.debug('****** absDiscPrice '+absDiscPrice);         
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));  
            System.debug('****** retailerMargin '+retailerMargin);         
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    System.debug('****** Flat Zrlg...');
                    percentage = rlg.Percentage__c;
                    break;
                }else if(retailerMargin > 1000 && rlg.Above_1000__c == true){
                    System.debug('***** Flat Above_1000 ...');
                    percentage = rlg.Percentage__c;
                    break;
                }else if(retailerMargin < 1000 && rlg.Below_1000__c == true){
                    System.debug('***** Flat Below_1000 ...');
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
        }  
        return percentage;
    }
    
    //Future
    public static void processOrderString(String JSON){
        
    }
}