trigger AddProductByDataImport on OpportunityLineItem (before insert) {
    
    Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
    
    set<string> OppNameSOSet =new set<string>();
    set<string> ProductNameSet =new set<string>();
    set<string> PricebookEntrySet =new set<string>();
    for(OpportunityLineItem oli1:trigger.new){
        OppNameSOSet.add(oli1.Sales_Order_Name__c);
        ProductNameSet.add(oli1.Product_Name_for_Insert__c);
        PricebookEntrySet.add(oli1.PricebookEntry_for_Insert__c);
    }
    
    List<Opportunity> OppfetchRecLst=[Select Id,Name,RecordTypeId from Opportunity where Name =: OppNameSOSet AND RecordTypeId=:kurlOnId];
    List <Product2> productFetch=[SELECT Id,Name FROM Product2 where Name =:ProductNameSet];
    List <PricebookEntry> priceBookFetch=[SELECT Id,Name,Pricebook2.Name FROM PricebookEntry where Name=:PricebookEntrySet
                                         AND Pricebook2.Name=:'KurlON to Retailer Price'];
    system.debug('OppfetchRecLst---->'+OppfetchRecLst);
    system.debug('productFetch---->'+productFetch);
    system.debug('priceBookFetch---->'+priceBookFetch);
    //ean on product & so number
    
    for(OpportunityLineItem oli2:trigger.new){
        for(Opportunity o:OppfetchRecLst){
            if(oli2.Sales_Order_Name__c==o.Name){
                system.debug('oli2'+oli2);
                system.debug('o'+o.Name);
                oli2.OpportunityId=o.Id;
                system.debug('oli2 for Sales Order--->'+oli2);
            }
        }
    }

    //Product
    for(OpportunityLineItem oli3:trigger.new){
        for(Product2 p:productFetch){
            if(oli3.Product_Name_for_Insert__c==p.Name){
                system.debug(oli3.Product_Name_for_Insert__c);
                system.debug(p.Name);
                oli3.Product2Id=p.Id;
                system.debug('oli3 for Product2--->'+oli3);
            }
        }
    }   
    //PricebookEntry
    for(OpportunityLineItem oli4:trigger.new){
        for(PricebookEntry pe:priceBookFetch){
            if(oli4.PricebookEntry_for_Insert__c==pe.Name){
                oli4.PricebookEntryId=pe.Id;
            }
        }
    }
}