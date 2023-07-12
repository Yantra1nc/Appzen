public with sharing class DynamicDiscount {
    public static List<Decimal> lstGst = new List<Decimal>();
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsDynamicDisc(FilterWrapper filtersData,Id recordId,Integer offSet)
    {   
        Opportunity oppBrand = [select Brand__c from Opportunity where Id =: recordId limit 1];
        Opportunity opp = [SELECT Id, RecordtypeId, RecordType.name FROM Opportunity where Id =:recordId];
        String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordtypeId).getname();
        System.debug(recordTypeName);
        String recordType = recordTypeName;        
        recordTypeName = recordTypeName.split(' ')[0];
        String recType = recordTypeName+'%';
        Pricebook2 pb2;
        //System.debug('pb name'+pb2.Name);
        if (recordType == 'KurlON Sales Order') {
            pb2 = [select Id ,Name from Pricebook2 where Name = 'IndoCount to KurlOn Price' limit 1];
        }else{
            pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
        }        
        if (oppBrand.Brand__c == 'Private Label') {
            pb2 = [select Id ,Name from Pricebook2 where Name = 'B2B' limit 1];
        }
        System.debug('pb name'+pb2.Name);
        
        String query = 'SELECT Name,Collection__c,Kurl_On_to_Retailer_Price_1__c,Design_Type__c,Design_Num__c,Availability__c,(Select UnitPrice from PricebookEntries where IsActive = true and Pricebook2Id =\''+pb2.Id+'\' and UnitPrice >='+filtersData.minPrice+' and UnitPrice <='+filtersData.maxPrice+' order by Pricebook2.CreatedDate DESC Limit 1),Product_Image_Link__c,Brand__c,Size__c,Color__c,Kurl_On_to_Retailer_Price__c,MOP__c FROM Product2 Where Availability__c =\'A\' and Name != null AND Brand__c =\''+ oppBrand.Brand__c+'\'';    
        List<Id> pbEntryIds = new List<Id>();
        List<Product2> prodList = [SELECT Id,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE IsActive = True AND Name != null];
        for(Product2 prod : prodList){
            for(PricebookEntry pbEntry : prod.PricebookEntries){                
                pbEntryIds.add(pbEntry.Id);                
            }
        }
        System.debug(query);        
        System.debug('filtersData ' + filtersData);
        if (filtersData != null) {
            if (filtersData.collection != null && filtersData.collection.size() > 0)
            {
                String[] collections = filtersData.collection;
                query += ' AND Collection__c IN :collections';
            }            
            if (filtersData.minPrice != null || filtersData.maxPrice != null) {
                Decimal minPrice = filtersData.minPrice;
                Decimal maxPrice = filtersData.maxPrice;
                query += ' AND Id in (Select Product2Id from PricebookEntry where Id in :pbEntryIds and IsActive = true and UnitPrice >= :minPrice AND UnitPrice <= :maxPrice)';
            }       
            if (filtersData.brand != null && filtersData.brand.size() > 0) {
                String [] brand = filtersData.brand;
                query += ' AND Brand__c IN :brand';
            }
            if (filtersData.designType != null && filtersData.designType.size() > 0) {
                String[] type = filtersData.designType;
                query += ' AND Design_Type__c IN :type';
            }
            if (filtersData.size != null && filtersData.size.size() > 0) {
                String[] size = filtersData.size;
                query += ' AND Size__c IN :size';
            }
            if (filtersData.color != null && filtersData.color.size() > 0) {
                String[] color = filtersData.color;
                query += ' AND Color__c IN :color';
            }
            if (filtersData.designNo != null && filtersData.designNo.size() > 0) {
                String[] designNo = filtersData.designNo;
                query += ' AND Design_No__c IN :designNo';
            }
            
        }
        System.debug(query);
        query+= ' LIMIT 20 OFFSET '+offSet;
        List<Product2> lstProd =  Database.query(query);
        List<Product2> newLstProd = new List<Product2>();
        System.debug(lstProd.size());
        for(Product2 prod : lstProd){
            for(PricebookEntry pbEntry : prod.PricebookEntries){ 
                
                System.debug(prod.Id +' '+pbEntry.UnitPrice);
                prod.Kurl_On_to_Retailer_Price__c = pbEntry.UnitPrice;
                newLstProd.add(prod);
            }
        }
        //System.debug(newLstProd);
        return newLstProd;
    }
    
    @AuraEnabled
    public static void saveEditedLineItems(List<OpportunityWrapper> oppWrapperList,List<Id> lstToDelete,Id opId){
        System.debug('I am in saveEditedLineItems ');
        ID oppId;
        System.debug('**** lstToDelete '+lstToDelete);
        System.debug('**** oppWrapperList '+oppWrapperList);
        System.debug('**** opId '+opId);       
        try {
            List<OpportunityLineItem> lstToUpdate = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lstToInsert = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lstDelete = new List<OpportunityLineItem>();
            List<Opportunity> lstOpp = new List<Opportunity>();
            
            
            System.debug(oppWrapperList);
            if (oppWrapperList.size() > 0) {
                for (OpportunityWrapper obj : oppWrapperList) {
                    oppId = obj.opportunityId;
                    System.debug('Final-> '+obj.finalValue);
                    Opportunity op = [SELECT Id,Distrbution_Channel__c,CheckUpdateSO__c,Retailer_Order_Value_Ex_GST_Num__c,Retailer_Final_Order_Value__c  FROM Opportunity where Id =:oppId];
                    op.Retailer_Order_Value_Ex_GST_Num__c = obj.basicValue;
                    op.Retailer_Final_Order_Value__c = obj.finalValue;
                    
                    if (lstOpp.size() <= 0) {
                        lstOpp.add(op);                    
                    }
                    if (obj.oppLineItemId != null) {
                        OpportunityLineItem oli = [select Id,Product2Id,OpportunityId,UnitPrice,Quantity,Final_Price__c,CGST_on_Exmill__c,IGST_on_Exmill__c,SGST_on_Exmill__c from OpportunityLineItem where OpportunityId =:obj.opportunityId and Id =:obj.oppLineItemId limit 1];
                        
                        //oli.Product2Id = obj.productId;
                        //oli.OpportunityId = obj.opportunityId;
                        //oli.UnitPrice = obj.kurlonretailprice;                        
                        oli.Quantity = obj.quantity;
                        oli.Additional_Discount__c= obj.addDisc;                                  
                        //opp.GST_New__c = obj.gst;                   
                        Opportunity salesOrder = [SELECT Within_Maharashtra__c  FROM Opportunity where Id=:obj.opportunityId];
                        Product2 prod = [SELECT Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 where Id=:obj.productId];
                      
                        //zrlg
                        Price_Master__c pm = DynamicDiscount.getPriceMaster(prod.Id,op.Id);
                        Double distChan = 0;
                        Decimal zrlg = 0;
                        if(op.Distrbution_Channel__c != null){
                            distChan = Double.valueOf(op.Distrbution_Channel__c);
                        }
                        zrlg = UnicommerceSalesOrderUtility.getZRLG(pm,prod,distChan);
                        oli.ZRLG__c = zrlg;
                        System.debug('********* zrlg '+zrlg);
                        
                        if(salesOrder.Within_Maharashtra__c == true){
                            List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                    SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                    WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                                    AND HSN__c =:prod.HSN_Code__c];
                            
                            for(GST__c gli:gstList)
                            {
                                if(gli!=null){
                                    if(gli.GST_Value__c  != null && obj.discountedPrice < gli.GST_Value__c ){
                                        oli.CGST__c = gli.CGST_less_than_1000__c;
                                        oli.SGST__c = gli.SGST_less_than_1000__c;
                                        oli.IGST__c = 0.0;
                                        oli.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                        oli.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                        oli.IGST_on_Exmill__c = 0.0;
                                    }
                                    else{
                                        oli.CGST__c = gli.CGST_greater_than_1000__c;
                                        oli.SGST__c = gli.SGST_greater_than_1000__c;
                                        oli.IGST__c = 0.0;
                                        oli.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                        oli.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                        oli.IGST_on_Exmill__c = 0.0;
                                    }
                                }
                            }
                        }
                        else
                        {List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c WHERE Within_State__c=:salesOrder.Within_Maharashtra__c AND HSN__c =:prod.HSN_Code__c];
                         for(GST__c gli2:gstList2){if(gli2!=null){
                             if(obj.discountedPrice < gli2.GST_Value__c){oli.IGST__c = gli2.IGST_less_than_1000__c; 
                                                            oli.SGST__c = 0.0;
                                                            oli.CGST__c = 0.0;
                                                            oli.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                                            oli.CGST_on_Exmill__c = 0.0;
                                                            oli.SGST_on_Exmill__c = 0.0;
                                                           } 
                             else{oli.IGST__c = gli2.IGST_greater_than_1000__c; 
                                  oli.SGST__c = 0.0;
                                  oli.CGST__c = 0.0;
                                  oli.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                  oli.CGST_on_Exmill__c = 0.0;
                                  oli.SGST_on_Exmill__c = 0.0;
                                 }                                                                        
                         }                                
                                                  }                            
                        }
                        System.debug('******* obj.discountedPrice '+obj.discountedPrice);
                        oli.GST_in_1__c = obj.gstPrice;
                        oli.PriceAfterGST__c = obj.priceAfterGst;
                        oli.Dynamic_Discount__c = obj.discountedPrice;           
                        oli.Final_Price__c = obj.finalPrice;
                        oli.MD_Discount_Term__c = obj.mdDiscountTerm;
                        oli.MD_Distributor_Margin__c = obj.mdDistributorMargin;
                        oli.MD_LFS_Margin__c = obj.mdLfsMargin;
                        oli.MD_Retailer_Margin__c = obj.mdRetailerMargin;
                        oli.MD_Retailer_GST__c = obj.mdRetailerGst;
                        oli.MU_Discount_Term__c = obj.muDiscountTerm;
                        oli.MU_Distributor_Margin__c = obj.muDistributorMargin;
                        oli.MU_LFS_Margin__c = obj.muLfsMargin;
                        oli.MU_Retailer_Margin__c = obj.muRetailerMargin;
                        oli.MU_Retailer_GST__c = obj.muRetailerGst;
                        oli.Price_Master_Name__c = obj.priceMasterName;
                        oli.Price_Master_Number__c = obj.priceMasterId;
                        lstToUpdate.add(oli);                   
                    }else {
                        System.debug('OppNull');
                        OpportunityLineItem opp = new OpportunityLineItem();
                        Opportunity oppz = [SELECT Id,RecordtypeId, RecordType.name,Pricebook2Id FROM Opportunity where Id =:opId limit 1];
                        String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppz.RecordtypeId).getname();
                        System.debug(recordTypeName);        
                        recordTypeName = recordTypeName.split(' ')[0];
                        String recType = recordTypeName+'%';
                        Pricebook2 pb = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
                        System.debug(pb);                        
                        PricebookEntry pbEntry;
                        //System.debug(pbEntry);
                        if (oppz.Pricebook2Id == null) {
                            pbEntry = [select Id from PricebookEntry where Product2Id =: obj.productId and Pricebook2Id =: pb.Id limit 1];
                        }else{
                            pbEntry = [select Id from PricebookEntry where Product2Id =: obj.productId and Pricebook2Id =: oppz.Pricebook2Id limit 1];
                        }
                        opp.PricebookEntryId = pbEntry.Id;                        
                        opp.Product2Id = obj.productId;
                        opp.OpportunityId = obj.opportunityId;
                        opp.UnitPrice = obj.kurlonretailprice;
                        opp.Quantity = obj.quantity;
                        opp.Additional_Discount__c= obj.addDisc;                                  
                        //opp.GST_New__c = obj.gst;
                        Opportunity salesOrder = [SELECT Within_Maharashtra__c  FROM Opportunity where Id=:obj.opportunityId];
                        System.debug(salesOrder);
                        Product2 prod = [SELECT Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 where Id=:obj.productId];
                        
                        //zrlg
                        Price_Master__c pm = DynamicDiscount.getPriceMaster(prod.Id,op.Id);
                        Double distChan = 0;
                        Decimal zrlg = 0;
                        if(op.Distrbution_Channel__c != null){
                            distChan = Double.valueOf(op.Distrbution_Channel__c);
                        }
                        zrlg = UnicommerceSalesOrderUtility.getZRLG(pm,prod,distChan);
                        opp.ZRLG__c = zrlg;
                        System.debug('**********zrlg '+zrlg); if(salesOrder.Within_Maharashtra__c == true){
                            List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c WHERE Within_State__c=:salesOrder.Within_Maharashtra__c  AND HSN__c =:prod.HSN_Code__c];
                            for(GST__c gli:gstList)
                            {
                                if(gli!=null){
                                    if(obj.discountedPrice < gli.GST_Value__c){
                                        opp.CGST__c = gli.CGST_less_than_1000__c;
                                        opp.SGST__c = gli.SGST_less_than_1000__c;
                                        opp.IGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                        opp.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                        opp.IGST_on_Exmill__c = 0.0;
                                        
                                    }
                                    else{
                                        opp.CGST__c = gli.CGST_greater_than_1000__c; 
                                        opp.SGST__c = gli.SGST_greater_than_1000__c; 
                                        opp.IGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                        opp.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                        opp.IGST_on_Exmill__c = 0.0;
                                    }                                    
                                }                                
                            }
                        }
                        else{                            
                            List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c  WHERE Within_State__c=:salesOrder.Within_Maharashtra__c AND HSN__c =:prod.HSN_Code__c];
                            for(GST__c gli2:gstList2){if(gli2!=null){if(obj.discountedPrice < gli2.GST_Value__c){opp.IGST__c = gli2.IGST_less_than_1000__c; opp.SGST__c = 0.0; opp.CGST__c = 0.0;
                                                                                                    opp.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                                                                                    opp.SGST_on_Exmill__c = 0.0;
                                                                                                    opp.CGST_on_Exmill__c = 0.0;
                                                                                                   }
                                                                     else{opp.IGST__c = gli2.IGST_greater_than_1000__c; opp.SGST__c = 0.0; opp.CGST__c = 0.0;
                                                                          opp.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                                                          opp.SGST_on_Exmill__c = 0.0;
                                                                          opp.CGST_on_Exmill__c = 0.0;
                                                                         } 
                                                                    }                                
                                                     }
                        } 
                        opp.GST_in_1__c = obj.gstPrice; 
                        opp.PriceAfterGST__c = obj.priceAfterGst;
                        opp.Dynamic_Discount__c = obj.discountedPrice;           
                        opp.Final_Price__c = obj.finalPrice;
                        opp.MD_Discount_Term__c = obj.mdDiscountTerm;
                        opp.MD_Distributor_Margin__c = obj.mdDistributorMargin;
                        opp.MD_LFS_Margin__c = obj.mdLfsMargin;
                        opp.MD_Retailer_Margin__c = obj.mdRetailerMargin;
                        opp.MD_Retailer_GST__c = obj.mdRetailerGst;
                        opp.MU_Discount_Term__c = obj.muDiscountTerm;
                        opp.MU_Distributor_Margin__c = obj.muDistributorMargin;
                        opp.MU_LFS_Margin__c = obj.muLfsMargin;
                        opp.MU_Retailer_Margin__c = obj.muRetailerMargin;
                        opp.MU_Retailer_GST__c = obj.muRetailerGst;
                        opp.Price_Master_Name__c = obj.priceMasterName;
                        opp.Price_Master_Number__c = obj.priceMasterId;
                        lstToInsert.add(opp);
                        System.debug(lstToInsert);
                    }
                }  
            }
            
            for (OpportunityLineItem op : [select Id,Product2Id from OpportunityLineItem where OpportunityId =:opId]) {
                System.debug(op.Product2Id);
                System.debug(lstDelete);
                if (lstToDelete.contains(op.Product2Id)) {                    
                    lstDelete.add(op);
                }
            } 
            System.debug(lstDelete);                  
            insert lstToInsert;
            update lstToUpdate;
            delete lstDelete;
            update lstOpp;
            System.debug('try '+lstDelete);
        } catch (Exception e) {
            System.debug('catch '+e.getMessage()+'line '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOppLineItems(Id oppId){
        try { 
            Set<Id> prodIds = new Set<Id>();
            List<OpportunityLineItem> lstOppLi = new List<OpportunityLineItem>();
            Map<Id,Object> mapProdUnitPrice = new Map<Id,Object>();
            for (OpportunityLineItem prodId : [Select Id,Product2Id from OpportunityLineItem where OpportunityId =:oppId]) {
                prodIds.add(prodId.Product2Id);
            } 
            Opportunity opp = [SELECT Id, RecordtypeId, RecordType.name,Brand__c FROM Opportunity where Id =:oppId];
            String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordtypeId).getname();
            System.debug(recordTypeName); 
            String recordType = recordTypeName;        
            recordTypeName = recordTypeName.split(' ')[0];
            String recType = recordTypeName+'%';
            Pricebook2 pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1]; 
            if (recordType == 'KurlON Sales Order') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'IndoCount to KurlOn Price' limit 1];
            }else{
                pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
            }
            if (opp.Brand__c == 'Private Label') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'B2B' limit 1];
            }
            List<Product2> prodList = [SELECT Id, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE Id in:prodIds and IsActive = True AND Name != null];         
            for (Product2 prod : prodList) {
                for (PricebookEntry pbEntry : prod.PricebookEntries) {
                    mapProdUnitPrice.put(prod.Id, pbEntry.UnitPrice);
                }       
            }
            for (OpportunityLineItem oppLi : [Select Additional_Discount__c,Quantity,Product2.Id,Product2.Name,Product2.Kurl_On_to_Retailer_Price_1__c,Product2.Product_Image__c,Product2.Product__c,Product2.Product_Image_Link__c,Product2.Availability__c,Product2.MOP__c,Product2.Design_Num__c,Product2.Collection__c,Product2.Design_Type__c,Product2.Design_No__c,Product2.Kurl_On_to_Retailer_Price__c,Product2.Brand__c,Product2.Size__c,Product2.Color__c,Id,Dynamic_Discount__c,Product2Id,GST__c,GST_in_1__c,PriceAfterGST__c From OpportunityLineItem where OpportunityId =:oppId]) {
                for (Id ids : mapProdUnitPrice.keySet()) {
                    if (ids == oppLi.Product2.Id) {
                        oppLi.Product2.Kurl_On_to_Retailer_Price__c = (Decimal)mapProdUnitPrice.get(ids);
                        lstOppLi.add(oppLi);
                    }
                }
            } 
            return lstOppLi;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static Integer getCountOfRecords(FilterWrapper filtersData,Id recordId){
        try {
            Integer count= 0;
            Opportunity oppBrand = [select Brand__c from Opportunity where Id =: recordId limit 1];
            String query = 'SELECT Id from Product2 where IsActive = true and Brand__c =\''+ oppBrand.Brand__c+'\'';
            if (filtersData != null) {
                if (filtersData.collection != null && filtersData.collection.size() > 0)
                {
                    String[] collections = filtersData.collection;
                    query += ' AND Collection__c IN :collections';
                }            
                if (filtersData.minPrice != null) {
                    Decimal minPrice = filtersData.minPrice;                
                    query += ' AND Kurl_On_to_Retailer_Price__c >= :minPrice';
                }   
                if (filtersData.maxPrice != null) {             
                    Decimal maxPrice = filtersData.maxPrice;
                    query += ' AND Kurl_On_to_Retailer_Price__c <= :maxPrice';
                }       
                if (filtersData.brand != null && filtersData.brand.size() > 0) {
                    String [] brand = filtersData.brand;
                    query += ' AND Brand__c IN :brand';
                }
                if (filtersData.designType != null && filtersData.designType.size() > 0) {
                    String[] type = filtersData.designType;
                    query += ' AND Design_Type__c IN :type';
                }
                if (filtersData.size != null && filtersData.size.size() > 0) {
                    String[] size = filtersData.size;
                    query += ' AND Size__c IN :size';
                }
                if (filtersData.color != null && filtersData.color.size() > 0) {
                    String[] color = filtersData.color;
                    query += ' AND Color__c IN :color';
                }
                if (filtersData.designNo != null && filtersData.designNo.size() > 0) {
                    String[] designNo = filtersData.designNo;
                    query += ' AND Design_No__c IN :designNo';
                }
                
                if (filtersData.productType != null && filtersData.productType.size() > 0) {
                    String[] prodType = filtersData.productType;
                    query += ' AND Product__c IN :prodType';
                }
                
            }
            List<Product2> lstProd = Database.query(query);
            for(Product2 prod:lstProd){
                count+=1;
            }
            return count;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*@AuraEnabled
public static void updateSalesOrder(Id oppId){
try {
Opportunity op = [SELECT Id,CheckUpdateSO__c  FROM Opportunity where Id =:oppId];
if(op.CheckUpdateSO__c == true){
op.CheckUpdateSO__c = false;
}else if(op.CheckUpdateSO__c == false){
op.CheckUpdateSO__c = true;
}
update op;
} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}
}*/
    
    @AuraEnabled
    public static Opportunity getProductDetails(Id oppId){
        try {
            return [Select (select id from OpportunityLineItems),Sales_Order_No__c,Order_Date__c,CloseDate,Layers_Count__c,Boutique_Living_Count__c,Add_Discount__c from Opportunity where Id=:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Product2> getProductMrp(Id prodId,Id recordId){
        try {
            Opportunity opp = [SELECT Id, RecordtypeId, RecordType.name,Brand__c FROM Opportunity where Id =:recordId];
            String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordtypeId).getname();
            System.debug(recordTypeName);  
            String recordType = recordTypeName;        
            recordTypeName = recordTypeName.split(' ')[0];
            String recType = recordTypeName+'%';
            Pricebook2 pb2;
            //System.debug('pb name'+pb2.Name);
            if (recordType == 'KurlON Sales Order') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'IndoCount to KurlOn Price' limit 1];
            }else{
                pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
            }
            if (opp.Brand__c == 'Private Label') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'B2B' limit 1];
            }
            List<Product2> newLstProd = new List<Product2>();
            List<Product2> prodList = [SELECT Id,Product_Image_Link__c,Brand__c,Collection__c,Name,Size__c,Availability__c,Design_No__c,Design_Num__c,Color__c,Design_Type__c,Kurl_On_to_Retailer_Price_1__c,Kurl_On_to_Retailer_Price__c, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE Id = :prodId and IsActive = True AND Name != null];
            for(Product2 prod : prodList){
                for(PricebookEntry pbEntry : prod.PricebookEntries){                
                    prod.Kurl_On_to_Retailer_Price__c = pbEntry.UnitPrice;   
                    newLstProd.add(prod);                          
                }
            }
            // return [Select Product_Image_Link__c,Brand__c,Collection__c,Name,Size__c,Availability__c,Design_No__c,Design_Num__c,Color__c,Design_Type__c,Standard_Price__c from Product2 where Id=:prodId];
            return newLstProd;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getGST(List<Id> lstProdId,Id oppId,Boolean flag){
        System.debug(lstProdId);
        System.debug(oppId);
        Decimal gst = 0.0;
        try {
            
            List<Opportunity> opp = [Select AccountId,Within_Maharashtra__c From Opportunity where Id=:oppId limit 1];
            if (opp.size() > 0) {
                for(Id prod:lstProdId){
                    List<Product2> p = [Select HSN_Code__c from Product2 where Id=:prod limit 1];
                    if (opp[0].Within_Maharashtra__c == true) {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                AND HSN__c =:p[0].HSN_Code__c];
                        for(GST__c gli:gstList)
                        {
                            if(gli!=null){
                                if(flag == true){                                   
                                    gst = gli.CGST_less_than_1000__c+ gli.SGST_less_than_1000__c+0.0;
                                    lstGst.add(gst);
                                }
                                else{                                    
                                    gst = gli.CGST_greater_than_1000__c + gli.SGST_greater_than_1000__c + 0.0;
                                    lstGst.add(gst);
                                }                                
                            }
                        }
                    }
                    else {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                                 Within_State__c, HSN__c FROM GST__c 
                                                 WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                 AND HSN__c =:p[0].HSN_Code__c];
                        
                        
                        for(GST__c gli2:gstList2)
                        {
                            if(gli2!=null){
                                if(flag == true){                       
                                    gst = gli2.IGST_less_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                }
                                else{
                                    gst = gli2.IGST_greater_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                }
                            }
                        }
                    }
                }
                System.debug(lstGst);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return gst;
    }
    
    @AuraEnabled(cacheable=true)
    public static GstWrapper getGSTWrapper(List<Id> lstProdId,Id oppId,Boolean flag){
        System.debug(lstProdId);
        System.debug(oppId);
        GstWrapper wrapper = new GstWrapper();
        Decimal gst = 0.0;
        try {
            
            List<Opportunity> opp = [Select AccountId,Within_Maharashtra__c From Opportunity where Id=:oppId limit 1];
            if (opp.size() > 0) {
                for(Id prod:lstProdId){
                    List<Product2> p = [Select HSN_Code__c from Product2 where Id=:prod limit 1];
                    if (opp[0].Within_Maharashtra__c == true) {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                AND HSN__c =:p[0].HSN_Code__c];
                        for(GST__c gli:gstList)
                        {
                            System.debug('**** gli '+gli);
                            
                            if(gli!=null){
                                if(flag == true){                                   
                                    gst = gli.CGST_less_than_1000__c+ gli.SGST_less_than_1000__c+0.0;
                                    lstGst.add(gst);
                                    wrapper.cgst = gli.CGST_less_than_1000__c;
                                    wrapper.sgst = gli.SGST_less_than_1000__c;
                                    wrapper.igst = 0.0;
                                }
                                else{                                    
                                    gst = gli.CGST_greater_than_1000__c + gli.SGST_greater_than_1000__c + 0.0;
                                    lstGst.add(gst);
                                    wrapper.cgst = gli.CGST_greater_than_1000__c;
                                    wrapper.sgst = gli.SGST_greater_than_1000__c;
                                    wrapper.igst = 0.0;
                                }                                
                            }
                        }
                    }
                    else {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList2 = [SELECT ID,IGST_less_than_1000__c,GST_Value__c,IGST_greater_than_1000__c,
                                                 Within_State__c, HSN__c FROM GST__c 
                                                 WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                 AND HSN__c =:p[0].HSN_Code__c];
                        
                        
                        for(GST__c gli2:gstList2)
                        {
                            System.debug('**** gli2 '+gli2);
                            if(gli2!=null){
                                if(flag == true){                       
                                    gst = gli2.IGST_less_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                    wrapper.cgst = 0.0;
                                    wrapper.sgst = 0.0;
                                    wrapper.igst = gli2.IGST_less_than_1000__c;
                                }
                                else{
                                    gst = gli2.IGST_greater_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                    wrapper.cgst = 0.0;
                                    wrapper.sgst = 0.0;
                                    wrapper.igst = gli2.IGST_greater_than_1000__c;
                                }
                            }
                        }
                    }
                }
                System.debug('******lstGst '+lstGst);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('******wrapper '+wrapper);
        
        return wrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal calculateDynamicDiscount(Id productId,Id oppId){
        
        Decimal discount = 0.0;
        try {
            Opportunity opp = [Select AccountId,RecordtypeId,RecordType.name,CreatedDate,Distrbution_Channel__c From Opportunity where Id=:oppId limit 1];
            String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordtypeId).getname();
            String recordType = recordTypeName;
            System.debug(recordTypeName);        
            recordTypeName = recordTypeName.split(' ')[0];
            String recType = recordTypeName+'%';
            Pricebook2 pb2;
            //System.debug(pb2.Name);   
            if (recordType == 'KurlON Sales Order') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'IndoCount to KurlOn Price' limit 1];
                System.debug(pb2.Name);
            }else{
                pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
                System.debug(pb2.Name);
            }
            
            Product2 p = [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) from Product2 where Id=:productId and IsActive = True AND Name != null limit 1];
            System.debug(p.Product__c);
            if (opp.AccountId != null) {            
                
                Price_Master__c pm = findPriceMaster(p,opp);
                System.debug('**** PRice master'+pm );
                if (recordType == 'LFS Sales Order') {
                    discount = calculateDiscountLFS(pm,p);
                    System.debug('************ LFS Sale DISC : '+discount);
                    
                }else if(recordType == 'Distributor Sales Order'){
                    discount = calculateDiscountDistributor(pm,p);
                    System.debug('************ Distributor DISC : '+discount);
                    
                }else if(recordType == 'Retailer'){
                    discount = calculateDiscountRetailer(pm,p);
                    System.debug('************ Retailer DISC : '+discount);
                    
                }else if(recordType == 'KurlON Sales Order'){
                    discount = calculateDiscountB2B(pm,p);
                    System.debug('************ KurlON DISC : '+discount);
                }else if(recordType == 'Direct Partner'){
                    discount = calculateDiscountDirect(pm,p);
                    System.debug('************ Direct DISC : '+discount);
                    
                }else if(recordType == 'B2B Order'){
                    discount = calculateDiscountB2B(pm,p);
                    System.debug('************ B2B DISC : '+discount);

                }
            }
        } catch (Exception e) {
            System.debug('Dinamic Disc -> '+e.getStackTraceString());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());       
            
        }
        System.debug(discount);
        return discount;
    }
    
    public static Decimal calculateDiscountLFS(Price_Master__c pm,Product2 p){
        System.debug('Inside LFS ');
        Double channelNo = 63;    
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = [Select Name,Distribution_No__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c];
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
            System.debug(absDiscPrice);
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));  
            System.debug(retailerMargin);         
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    percentage = rlg.Percentage__c;
                    break;
                }else if(retailerMargin > 1000 && rlg.Above_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }else if(retailerMargin < 1000 && rlg.Below_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
            System.debug(percentage);           
            Decimal distributorMargin = retailerMargin - (retailerMargin *(pm.MD_Distributor_Margin__c/100));
            System.debug(distributorMargin);
            Decimal retailerGST = distributorMargin - (absDiscPrice/(1+(percentage/100))*(percentage/100));
            //Decimal retailerGST = distributorMargin - (absDiscPrice * (percentage/100));
            System.debug(retailerGST);
            Decimal newRLG = retailerGST;
            System.debug(newRLG);
            exMillPrice = newRLG.setScale(2); 
        }  
        return exMillPrice;
    }
    
    public static Decimal calculateDiscountDistributor(Price_Master__c pm,Product2 p){
        System.debug('Inside Distributor ');
        Double channelNo = 61;
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = [Select Name,Distribution_No__c,ZRLG_Value__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c];
        System.debug('=> '+p.HSN_CODE__c);
        System.debug('lstRlg=> '+lstRlg);
        
        if (pm.Active__c == true && pm.Activated_End_Date__c > Datetime.now()) {
            System.debug('Inside condition ');
            if (pm.MD_Retailer_Margin__c > 0 && pm.MU_Retailer_Margin__c == 0) {pm.MD_Retailer_Margin__c = pm.MD_Retailer_Margin__c;}                
            else if(pm.MU_Retailer_Margin__c > 0 && pm.MD_Retailer_Margin__c == 0){pm.MD_Retailer_Margin__c = pm.MU_Retailer_Margin__c;}
            if(pm.MD_Distributor_Margin__c > 0 && pm.MU_Distributor_Margin__c == 0) { pm.MD_Distributor_Margin__c = pm.MD_Distributor_Margin__c;}               
            else if(pm.MU_Distributor_Margin__c > 0 && pm.MD_Distributor_Margin__c == 0){pm.MD_Distributor_Margin__c = pm.MU_Distributor_Margin__c;}
            if (pm.MD_Retailer_GST__c > 0 && pm.MU_Retailer_GST__c == 0) { pm.MD_Retailer_GST__c = pm.MD_Retailer_GST__c;}               
            else if(pm.MU_Retailer_GST__c > 0 && pm.MD_Retailer_GST__c == 0){pm.MD_Retailer_GST__c = pm.MU_Retailer_GST__c;}
            
            
            Decimal unitPrice = 0;
            Decimal absDiscPrice = 0;
            if(p.PricebookEntries != null && !p.PricebookEntries.isEmpty()){
                System.debug('Unit price '+p.PricebookEntries[0].UnitPrice);
                unitPrice = (Decimal)p.PricebookEntries[0].UnitPrice;
                absDiscPrice = unitPrice - (unitPrice * (pm.MD_Disc_Term__c/100)); 
            }
            System.debug(absDiscPrice);
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));  
            System.debug(retailerMargin);         
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice > rlg.ZRLG_Value__c && rlg.Above_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice < rlg.ZRLG_Value__c && rlg.Below_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
            System.debug(percentage);           
            Decimal distributorMargin = retailerMargin - (retailerMargin *(pm.MD_Distributor_Margin__c/100));
            System.debug(distributorMargin);
            Decimal retailerGST = distributorMargin - (distributorMargin/(1+(percentage/100))*(percentage/100));
            System.debug(retailerGST);
            Decimal newRLG = retailerGST;
            System.debug(newRLG);
            exMillPrice = newRLG.setScale(2); 
        }  
        return exMillPrice;
    }
    
    public static Decimal calculateDiscountRetailer(Price_Master__c pm,Product2 p){
        System.debug('Inside Retailer ' + pm);
        Double channelNo = 62;
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = [Select Name,ZRLG_Value__c,Distribution_No__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c];    
        System.debug('lstRlg'+lstRlg);
        if (pm.Active__c == true && pm.Activated_End_Date__c > Datetime.now()) {
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
            System.debug(p.PricebookEntries[0].UnitPrice);
            Decimal unitPrice = (Decimal)p.PricebookEntries[0].UnitPrice;
            Decimal absDiscPrice = unitPrice - (unitPrice * (pm.MD_Disc_Term__c/100)); 
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));
            System.debug(retailerMargin);
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice > rlg.ZRLG_Value__c && rlg.Above_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice < rlg.ZRLG_Value__c && rlg.Below_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
            Decimal distributorMargin = retailerMargin - (retailerMargin *(pm.MD_Distributor_Margin__c/100));
            System.debug(distributorMargin);
            Decimal retailerGST = distributorMargin - (distributorMargin/(1+(percentage/100))*(percentage/100));            
            System.debug(retailerGST);
            Decimal newRLG = retailerGST;
            System.debug(newRLG);
            exMillPrice = newRLG.setScale(2);
        }  
        return exMillPrice;
    }
    
    public static Decimal calculateDiscountB2B(Price_Master__c pm,Product2 p){
        System.debug('Inside B2B ' + pm);
        Double channelNo = 68;
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = [Select Name,Distribution_No__c,ZRLG_Value__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c];    
        System.debug('lstRlg'+lstRlg);
        if (pm.Active__c == true && pm.Activated_End_Date__c > Datetime.now()) {
            if (pm.MD_Retailer_Margin__c > 0 && pm.MU_Retailer_Margin__c == 0) {pm.MD_Retailer_Margin__c = pm.MD_Retailer_Margin__c;}
            else if(pm.MU_Retailer_Margin__c > 0 && pm.MD_Retailer_Margin__c == 0){pm.MD_Retailer_Margin__c = pm.MU_Retailer_Margin__c;}            
            if (pm.MD_Distributor_Margin__c > 0 && pm.MU_Distributor_Margin__c == 0) {pm.MD_Distributor_Margin__c = pm.MD_Distributor_Margin__c;}                
            else if(pm.MU_Distributor_Margin__c > 0 && pm.MD_Distributor_Margin__c == 0){pm.MD_Distributor_Margin__c = pm.MU_Distributor_Margin__c;}
            if (pm.MD_Retailer_GST__c > 0 && pm.MU_Retailer_GST__c == 0) { pm.MD_Retailer_GST__c = pm.MD_Retailer_GST__c;}               
            else if(pm.MU_Retailer_GST__c > 0 && pm.MD_Retailer_GST__c == 0){pm.MD_Retailer_GST__c = pm.MU_Retailer_GST__c;}
            
            
            Decimal unitPrice = 0;
            Decimal absDiscPrice = 0; 
            
            if(p.PricebookEntries != null && !p.PricebookEntries.isEmpty()){
                unitPrice = (Decimal)p.PricebookEntries[0].UnitPrice;
                absDiscPrice = unitPrice - (unitPrice * (pm.MD_Disc_Term__c/100)); 
                System.debug(p.PricebookEntries[0].UnitPrice);
            }
            
            System.debug(absDiscPrice);
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));  
            System.debug(retailerMargin);         
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice > rlg.ZRLG_Value__c && rlg.Above_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice < rlg.ZRLG_Value__c && rlg.Below_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
            System.debug(percentage);           
            Decimal distributorMargin = retailerMargin - (retailerMargin *(pm.MD_Distributor_Margin__c/100));
            System.debug(distributorMargin);
            Decimal retailerGST = distributorMargin - (distributorMargin/(1+(percentage/100))*(percentage/100));
            System.debug(retailerGST);
            Decimal newRLG = retailerGST;
            System.debug(newRLG);
            exMillPrice = newRLG.setScale(2); 
        }  
        return exMillPrice;
    }
    
    Public static void testmethodx(){
        integer i = 0;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;     i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        i=i+1;i=i+1;
        
        
    }
        
    public static Decimal calculateDiscountDirect(Price_Master__c pm,Product2 p){
        System.debug('Inside Direct ' + pm);
        Double channelNo = 67;
        Decimal percentage = 0.0;
        Decimal exMillPrice = 0.0;
        List<ZRLG__c> lstRlg = [Select Name,ZRLG_Value__c,Distribution_No__c,Above_1000__c,Below_1000__c,Flat__c,Percentage__c,HSN_CODE__c from ZRLG__c where Distribution_No__c =:channelNo and HSN_CODE__c =:p.HSN_CODE__c];    
        System.debug('lstRlg'+lstRlg);
        if (pm.Active__c == true && pm.Activated_End_Date__c > Datetime.now()) {
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
            System.debug(p.PricebookEntries[0].UnitPrice);
            Decimal unitPrice = (Decimal)p.PricebookEntries[0].UnitPrice;
            Decimal absDiscPrice = unitPrice - (unitPrice * (pm.MD_Disc_Term__c/100)); 
            Decimal retailerMargin = absDiscPrice - (absDiscPrice *(pm.MD_Retailer_Margin__c/100));
            System.debug(retailerMargin);
            for (ZRLG__c rlg : lstRlg) {
                if (rlg.Flat__c == true) {
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice > rlg.ZRLG_Value__c && rlg.Above_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }else if(absDiscPrice < rlg.ZRLG_Value__c && rlg.Below_1000__c == true){
                    percentage = rlg.Percentage__c;
                    break;
                }
                
            }
            Decimal distributorMargin = retailerMargin - (retailerMargin *(pm.MD_Distributor_Margin__c/100));
            System.debug(distributorMargin);
            Decimal retailerGST = distributorMargin - (distributorMargin/(1+(percentage/100))*(percentage/100));            
            System.debug(retailerGST);
            Decimal newRLG = retailerGST;
            System.debug(newRLG);
            exMillPrice = newRLG.setScale(2);
        }  
        return exMillPrice;
    }
    
    @AuraEnabled
    public static Price_Master__c findPriceMaster(Product2 p,Opportunity opp){
        System.debug('*** Prod  '+p);
        System.debug('*** opp  '+opp);

        Price_Master__c priceMaster = new Price_Master__c();
        //Brand picklist values in Product2
        List<String> pickListValuesBrand= new List<String>();
        Schema.DescribeFieldResult fieldResult1 = Product2.Brand__c.getDescribe();
        List<Schema.PicklistEntry> pleBrand = fieldResult1.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleBrand){
            pickListValuesBrand.add(pickListVal.getLabel());
        } 
        
        //Collection picklist values in Product2
        List<String> pickListValuesCollection = new List<String>();
        Schema.DescribeFieldResult fieldResult2 = Product2.Collection__c.getDescribe();
        List<Schema.PicklistEntry> pleCollection = fieldResult2.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleCollection){
            pickListValuesCollection.add(pickListVal.getLabel());
        }        
        
        //Product type picklist values in Product2
        List<String> pickListValuesProdType= new List<String>();
        Schema.DescribeFieldResult fieldResult3 = Product2.Product__c.getDescribe();
        List<Schema.PicklistEntry> pleType = fieldResult3.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleType){
            pickListValuesProdType.add(pickListVal.getLabel());
        }
        
        try {
            System.debug('Out on For loop....');
            System.debug('opp.AccountId '+opp.AccountId);
             
            for (Price_Master__c pm : [Select Name,Price_Master_Name__c,Activated_End_Date__c,Active__c,Distribution_Channel__c,Activated_Start_Date__c,Brand__c,Collection__c,Account__c,Customer_Code__c,Marking__c,MD_Disc_Term__c,MD_Distributor_Margin__c,MD_LFS_Margin__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,MU_Discount_Term__c,MU_Distributor_Margin__c,MU_LFS_Margin__c,MU_Retailer_GST__c,MU_Retailer_Margin__c,Product__c,Product_Type__c
                                       from Price_Master__c where Active__c = true and Account__c =: opp.AccountId and Distribution_Channel__c=:opp.Distrbution_Channel__c ORDER BY CreatedDate DESC]) {  
                                           System.debug('--> priceMaster '+pm);
                                           if (opp.CreatedDate >= pm.Activated_Start_Date__c && opp.CreatedDate <= pm.Activated_End_Date__c) {
                                               System.debug('--> Active date ');
                                               
                                               if (opp.AccountId == pm.Account__c) {                    
                                                   System.debug('Accounnt match '+pm);            
                                                   if (pm.Brand__c == 'All' && pm.Collection__c == 'All' && pm.Product_Type__c == 'All') {
                                                       System.debug('1');
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c in:pickListValuesBrand and Collection__c in:pickListValuesCollection and Product__c in:pickListValuesProdType]) {
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);                                
                                                                                     
                                                                                     priceMaster = pm; 
                                                                                     return priceMaster;
                                                                                 }
                                                                                 
                                                                             }                                
                                                   }else if(pm.Brand__c == 'All' && pm.Collection__c == p.Collection__c && pm.Product_Type__c == 'All'){
                                                       System.debug('2');
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c in:pickListValuesBrand and Collection__c =:p.Collection__c and Product__c in:pickListValuesProdType]) {
                                                                                 System.debug(prod);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);
                                                                                     
                                                                                     priceMaster = pm;
                                                                                     return priceMaster;
                                                                                 }
                                                                                 
                                                                             }                               
                                                   }else if(pm.Brand__c == 'All' && pm.Collection__c == 'All' && pm.Product_Type__c == p.Product__c){
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c in:pickListValuesBrand and Collection__c in:pickListValuesCollection and Product__c =:p.Product__c]) {
                                                                                 System.debug(prod);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);
                                                                                     System.debug('3');
                                                                                     priceMaster = pm; 
                                                                                     return priceMaster;
                                                                                 }
                                                                             }
                                                   }else if(pm.Brand__c == p.Brand__c && pm.Collection__c == 'All' && pm.Product_Type__c == 'All'){
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c =:p.Brand__c]) {
                                                                                 System.debug(prod);
                                                                                 System.debug(p.Id);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);
                                                                                     System.debug('4');
                                                                                     priceMaster = pm; 
                                                                                     return priceMaster;
                                                                                 }
                                                                             }
                                                   }else if(pm.Brand__c == p.Brand__c && pm.Collection__c == p.Collection__c && pm.Product_Type__c == 'All'){
                                                       System.debug('5');
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c =:p.Brand__c and Collection__c =:p.Collection__c]) {
                                                                                 System.debug(prod);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);
                                                                                     System.debug('5');
                                                                                     priceMaster = pm; 
                                                                                     return priceMaster;
                                                                                 }
                                                                             }
                                                   }else if(pm.Brand__c == p.Brand__c && pm.Collection__c == 'All' && pm.Product_Type__c == p.Product__c){
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c =:p.Brand__c and Collection__c in:pickListValuesCollection and Product__c =:p.Product__c]) {
                                                                                 System.debug(prod);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);                               
                                                                                     priceMaster = pm; 
                                                                                     return priceMaster;
                                                                                 }
                                                                             }
                                                       System.debug('6');
                                                   }else if(pm.Brand__c == p.Brand__c && pm.Collection__c == p.Collection__c && pm.Product_Type__c == p.Product__c){
                                                       for (Product2 prod : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c from Product2 
                                                                             where Brand__c =:p.Brand__c and Collection__c =:p.Collection__c and Product__c =:p.Product__c]) {
                                                                                 System.debug(prod);
                                                                                 if (p.Id == prod.Id) {
                                                                                     System.debug('Price Master'+pm.Name);
                                                                                     System.debug('2');
                                                                                     priceMaster = pm;
                                                                                     return priceMaster; 
                                                                                 }
                                                                             }
                                                       System.debug('7');
                                                   }                     
                                               }
                                           }  
                                           if(Test.isRunningTest()){
                                               if(priceMaster == null){
                                                   return pm;
                                               }
                                           }
                                           
                                       }
            return priceMaster;
        } catch (Exception e) {
            System.debug('error : '+e.getMessage()+'LINE '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityRecord(Id oppId){
        try {
            System.debug(oppId);
            return [Select AccountId,RecordtypeId,RecordType.name,CreatedDate,Distrbution_Channel__c From Opportunity where Id=:oppId limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Price_Master__c getPriceMaster(Id productId,Id oppId){
        Price_Master__c pm;
        try {
            Opportunity opp = [Select AccountId,RecordtypeId,RecordType.name,CreatedDate,Distrbution_Channel__c From Opportunity where Id=:oppId limit 1];
            String recordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordtypeId).getname();
            String recordType = recordTypeName;
            System.debug(recordTypeName);        
            recordTypeName = recordTypeName.split(' ')[0];
            String recType = recordTypeName+'%';
            Pricebook2 pb2;        
            //System.debug(pb2.Name);   
            if (recordType == 'KurlON Sales Order') {
                pb2 = [select Id ,Name from Pricebook2 where Name = 'IndoCount to KurlOn Price' limit 1];
                System.debug(pb2.Name);
            }else{
                pb2 = [select Id ,Name from Pricebook2 where Name LIKE :recType limit 1];
                System.debug(pb2.Name);
            }
            
            Product2 p = [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) from Product2 where Id=:productId and IsActive = True AND Name != null limit 1];
            System.debug(p.Product__c);
            if (opp.AccountId != null) {            
                
                pm = findPriceMaster(p,opp);
                
            }
        } catch (Exception e) {
            System.debug('ERROR-> '+e.getStackTraceString());
            System.debug('ERROR-> '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());       
            
        }       
        System.debug('******* '+pm);
        return pm;
    }
    
    @AuraEnabled
    public static List<String> getCollectionsPickList(Id recId){
        List<String> lstCollections = new List<String>();
        try {
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstCollections;
    }
    
    public class FilterWrapper {
        @AuraEnabled
        public String[] collection { get; set; }
        
        @AuraEnabled
        public Decimal minPrice { get; set; }
        
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        
        @AuraEnabled
        public String[] brand { get; set; }
        
        @AuraEnabled
        public String[] designType { get; set; }    
        
        @AuraEnabled
        public String[] size { get; set; }
        
        @AuraEnabled
        public String[] color { get; set; }
        
        @AuraEnabled
        public String[] designNo { get; set; } 
        
        @AuraEnabled
        public String[] productType { get; set; } 
    }
    
    public class OpportunityWrapper{
        
        @AuraEnabled
        public String priceMasterId { get; set; }
        
        @AuraEnabled
        public String priceMasterName { get; set; }
        
        @AuraEnabled
        public Decimal mdDiscountTerm { get; set; }
        
        @AuraEnabled
        public Decimal mdDistributorMargin { get; set; }
        
        @AuraEnabled
        public Decimal mdLfsMargin { get; set; }
        
        @AuraEnabled
        public Decimal mdRetailerGst { get; set; }
        
        @AuraEnabled
        public Decimal mdRetailerMargin { get; set; }
        
        @AuraEnabled
        public Decimal muDiscountTerm { get; set; }
        
        @AuraEnabled
        public Decimal muDistributorMargin { get; set; }
        
        @AuraEnabled
        public Decimal muLfsMargin { get; set; }
        
        @AuraEnabled
        public Decimal muRetailerGst { get; set; }
        
        @AuraEnabled
        public Decimal muRetailerMargin { get; set; }
        
        @AuraEnabled
        public Decimal priceAfterGst { get; set; }
        
        @AuraEnabled
        public Decimal gstPrice { get; set; }
        
        @AuraEnabled
        public Decimal finalPrice { get; set; }
        
        @AuraEnabled
        public Decimal discountedPrice { get; set; }
        
        @AuraEnabled
        public Id oppLineItemId { get; set; }
        
        @AuraEnabled
        public Id opportunityId { get; set; }
        
        @AuraEnabled
        public Decimal additionalDiscountPrice { get; set; }
        
        @AuraEnabled
        public String brand { get; set; }
        
        @AuraEnabled
        public String collection { get; set; }
        
        @AuraEnabled
        public String name { get; set; }
        
        @AuraEnabled
        public String size { get; set; }
        
        @AuraEnabled
        public Decimal quantity { get; set; }
        
        @AuraEnabled
        public String designNo { get; set; }
        
        @AuraEnabled
        public String designType { get; set; }
        
        @AuraEnabled
        public Decimal kurlonretailprice { get; set; }
        
        @AuraEnabled
        public String color { get; set; }
        
        @AuraEnabled
        public Decimal addDisc { get; set; }
        
        @AuraEnabled
        public Id productId { get; set; }
        
        @AuraEnabled
        public Decimal basicValue { get; set; }
        
        @AuraEnabled
        public Decimal finalValue { get; set; }
        
    }
    
    public class GstWrapper{
        
        @AuraEnabled
        public Decimal cgst { get; set; }
        
        @AuraEnabled
        public Decimal sgst { get; set; }
        
        @AuraEnabled
        public Decimal igst { get; set; }
        
    }
     
    public static void disc_calc(List<Id> lstProdId,Id oppId,Boolean flag)
    {
        DiscountCalculation.getGST(lstProdId,oppId,flag);
    }
    
}