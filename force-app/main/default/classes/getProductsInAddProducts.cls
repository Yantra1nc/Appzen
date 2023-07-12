public with sharing class getProductsInAddProducts {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(FilterWrapper filtersData,Id recordId,Integer offSet)
    {   Opportunity oppBrand = [select Brand__c from Opportunity where Id =: recordId limit 1];
        
        String query = 'SELECT Name, Product_Image__c,Product__c,Product_Image_Link__c,Availability__c,MOP__c,Design_Num__c,Collection__c,Design_Type__c,Design_No__c,Kurl_On_to_Retailer_Price__c,Brand__c,Size__c,Color__c FROM Product2 Where IsActive = true AND Brand__c =\''+ oppBrand.Brand__c+'\''; 
        /*List<Id> pbEntryIds = new List<Id>();
        List<Product2> prodList = [SELECT Id, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE IsActive = True AND Name != null];
        for(Product2 prod : prodList){
            for(PricebookEntry pbEntry : prod.PricebookEntries){                
                pbEntryIds.add(pbEntry.Id);
            }
        }*/
        System.debug(query);        
        System.debug('filtersData ' + filtersData);
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
        query+= ' LIMIT 20 OFFSET '+offSet; 
        System.debug(query);    
        return (Product2[]) Database.query(query);
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
     
    @AuraEnabled
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
    }
     

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOppLineItems(Id oppId){
        try {
            System.debug(oppId);
            return [Select Quantity,Product2.Name,Product2.Product_Image__c,Product2.Product__c,Product2.Product_Image_Link__c,Product2.Availability__c,Product2.MOP__c,Product2.Design_Num__c,Product2.Collection__c,Product2.Design_Type__c,Product2.Design_No__c,Product2.Kurl_On_to_Retailer_Price__c,Product2.Brand__c,Product2.Size__c,Product2.Color__c,Id,Product2Id,GST__c,Additional_Discount__c From OpportunityLineItem where OpportunityId =:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String,String> getCountCollections(){
        try {
            Map<String,String> mapCollections = new Map<String,String>();
            for (AggregateResult ar : [SELECT Collection__c, COUNT(Id) recordCount FROM Product2 GROUP BY Collection__c]){
                String collection = (String) ar.get('Collection__c');
                Integer count = (Integer) ar.get('recordCount');
                mapCollections.put(collection, collection+' ('+count+')');
            }
            return mapCollections;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Opportunity getProductDetails(Id oppId){
        try {
            return [Select Sales_Order_No__c,Order_Date__c,CloseDate,Layers_Count__c,Boutique_Living_Count__c,Add_Discount__c from Opportunity where Id=:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Product2 getProductMrp(Id prodId){
        try {
            list<Product2> prdlist = new list<Product2>();
            prdlist = [Select Product_Image_Link__c,Brand__c,Collection__c,Name,Size__c,Availability__c,Design_No__c,Design_Num__c,Color__c,Design_Type__c,MOP__c,Kurl_On_to_Retailer_Price__c from Product2 where Id=:prodId ];
           system.debug('prdlist'+ prdlist.size() );
            return [Select Product_Image_Link__c,Brand__c,Collection__c,Name,Size__c,Availability__c,Design_No__c,Design_Num__c,Color__c,Design_Type__c,MOP__c,Kurl_On_to_Retailer_Price__c from Product2 where Id=:prodId ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
}