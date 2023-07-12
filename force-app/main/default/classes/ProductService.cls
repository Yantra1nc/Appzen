public with sharing class ProductService {
	@AuraEnabled(cacheable=true)
	public static List<Product2> getProducts(FilterWrapper filtersData)
	 {	
		//String pbId = '01sO0000000cZYN'; 
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];        
		String query = 'SELECT Name, Collection__c,Design_Type__c,(Select UnitPrice,UseStandardPrice from PricebookEntries where IsActive = true and Pricebook2Id =\''+pb2.Id+'\' and UnitPrice >='+filtersData.minPrice+' and UnitPrice <='+filtersData.maxPrice+'order by Pricebook2.CreatedDate DESC Limit 1),Product_Image_Link__c,Brand__c,Size__c,Color__c FROM Product2 Where Name != null';	
		List<Id> pbEntryIds = new List<Id>();
        List<Product2> prodList = [SELECT Id, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True and Pricebook2Id =: pb2.Id ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE IsActive = True AND Name != null];
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
		return (Product2[]) Database.query(query);
	 }

	/*@AuraEnabled
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
	}*/

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
		public String[] prodType { get; set; } 
    }
}