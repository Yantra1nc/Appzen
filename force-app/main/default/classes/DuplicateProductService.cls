public with sharing class DuplicateProductService {
	@AuraEnabled(cacheable=true)
	public static List<Product2> getProducts(FilterWrapper filtersData)
	 {	
		String query = 'SELECT Name, Collection__c,Design_Type__c,Design_Number__c,Product__c,Kurl_On_to_Retailer_Price__c,(Select UnitPrice,UseStandardPrice from PricebookEntries where IsActive = true and UnitPrice >='+filtersData.minPrice+' and UnitPrice <='+filtersData.maxPrice+'order by Pricebook2.CreatedDate DESC Limit 1),Product_Image_Link__c,Brand__c,Size__c,Color__c FROM Product2 Where Name != null';	
		List<Id> pbEntryIds = new List<Id>();
        List<Product2> prodList = [SELECT Id, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 WHERE IsActive = True AND Name != null];
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
   /* @AuraEnabled(cacheable=true)
    public static void setOppLineItem(List<Object> oppLineItemData){
        System.debug('oppLineItems'+ oppLineItemData);
        for(Object obj:oppLineItemData){
            Map<Object, Object> recMap = (Map<Object, Object>)obj;
            List<String> Brand = (List<String>)recMap.get('Brand');
            System.debug(Brand);
        }
        
    }*/

	@AuraEnabled
	public static void getDiscount(Id pId, Id recordId){
		System.debug('Product Id' + pId);
		System.debug('Record Id' + recordId);
		List<Id>lineItemIdLst = new List<Id>();
		List<opportunity> lineItemArray = new List<opportunity>();
		lineItemArray = [SELECT Id, (Select Id, name From OpportunityLineItems) From Opportunity where id =:recordId];
		for(Opportunity item: lineItemArray)
		{
			lineItemIdLst.add(item.id);
		}
		//List<Price_Master__c> lsts1 = [Select Collection__c, Account__c, Absolute_Disc_Term__c, Retailer__c, RetailerLocGST_on_MRP__c, LFS__c, District__c from Price_Master__c where Product__c =:lineItemIdLst[0].pId LIMIT 1];
		//System.debug(lsts1);
		/* for(Price_Master__c lst : lsts1) {
                
			if(lst != null){                
				ol.Absolute_Disc_Term__c = lst.Absolute_Disc_Term__c;
				ol.Retailer_Margin_MRP_from_District__c = lst.Retailer__c;
				ol.Retailer_LocGSTonMRP__c = lst.RetailerLocGST_on_MRP__c;
				ol.LFS_Margin_MRP_from_Indo_Retailer__c = lst.LFS__c;
				ol.District__c = lst.District__c;
				Decimal discount = (lst.Absolute_Disc_Term__c+lst.Retailer__c+lst.RetailerLocGST_on_MRP__c+lst.LFS__c+lst.District__c);
				ol.Discount = discount;
				//     ol.TotalPrice = (((ol.GST__c * ol.TotalPrice )/100) + ol.TotalPrice );
			}
		}  */
	}

    @AuraEnabled
    public static void setOppLineItem(List<LineItemWrapper> lineItemWrpData){
        System.debug('oppLineItems'+ lineItemWrpData);
        List<OpportunityLineItem> lineItemLst = new List<OpportunityLineItem>();
        for(LineItemWrapper lineItemObj:lineItemWrpData){
            System.debug(lineItemObj);
            OpportunityLineItem lineItemRec = new OpportunityLineItem();
            //lineItemRec.Collection__c = lineItemObj.collection;
           // lineItemRec.Brand__c = lineItemObj.brand;
            lineItemLst.add(lineItemRec);
            System.debug(lineItemLst);
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
    }
    
    public class LineItemWrapper {
		@AuraEnabled
		public String collection { get; set; }

		@AuraEnabled
		public String brand { get; set; }
         
    }
}