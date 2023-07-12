public with sharing class getProductsDuplicate {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(FilterWrapper filtersData,Id recordId)
     {  Opportunity oppBrand = [select Brand__c from Opportunity where Id =: recordId limit 1];
        
        String query = 'SELECT Name, Product_Image__c,Product__c,Product_Image_Link__c,Availability__c,MOP__c,Collection__c,Design_Type__c,Design_No__c,Kurl_On_to_Retailer_Price__c,Brand__c,Size__c,Color__c FROM Product2 Where IsActive = true';    
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
        System.debug(query);
        return (Product2[]) Database.query(query);
     }

     /*@AuraEnabled
     public static void saveLineItems(List<OppWrapperClass> oppWrapperList){
         try {
            System.debug(oppWrapperList);
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
     }*/

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOppLineItems(Id oppId){
        try {
            return [Select Quantity,Product2.Name, Id, Product2Id, Product2.Kurl_On_to_Retailer_Price__c,Product2.Brand__c,GST__c From OpportunityLineItem where OpportunityId =:oppId];
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
            return [Select Product_Image_Link__c,Brand__c,Collection__c,Name,Size__c,Availability__c,Design_No__c,Color__c,Design_Type__c,MOP__c,Kurl_On_to_Retailer_Price__c from Product2 where Id=:prodId];
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