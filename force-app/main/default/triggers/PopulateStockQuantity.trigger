trigger PopulateStockQuantity on Product2 (before insert, before update) {
    
    Double sumofstock =0.00;
    for(Product2 prod : Trigger.new){
        
        AggregateResult[] groupedResults = [Select Product_del__c, sum(Stock__c)sum from Stock__c where Product_del__c =:prod.Id
                                            Group by Product_del__c];
        
        for(AggregateResult grp : groupedResults){
            if(grp != null){
                sumofstock = double.valueOf(groupedResults[0].get('sum'));  
                prod.Stock_Quantity__c = sumofstock;
            }
        }
        
    }
    
}