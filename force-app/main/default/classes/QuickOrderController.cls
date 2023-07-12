public class QuickOrderController{
    
    public QuickOrderController() {
        
    }
    
    @AuraEnabled
    public static Map<String, String> queryProducts() {
        Map<String, String> products = new Map<String, String>();
        for(Product2 pd : [select ID, Name from Product2 Limit 1000])           {
            products.put(pd.id, pd.Name);     
        }
        return products;
    } 
    
    @AuraEnabled
    public static List<account> queryAccounts(String recordId, string searchKeyWord) {
        List<account> accountsList = new List<account>();
        system.debug('searchKeyWord-->'+searchKeyWord);
        String searchKey = '%'+searchKeyWord + '%';
        string Code = [Select id,Customer_Code_SOP__c From Opportunity Where id =:recordId].Customer_Code_SOP__c;
        System.debug('customerCode-->'+Code);
        if(string.isNotBlank(searchKeyWord)){
            for(Account ac : [select ID, Name,Service_Tax_Number__c,Customer_Code_SOP__c,BillingAddress,ShippingAddress,Shipping_Address_Formula__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCOde from Account Where Shipping_Address_Formula__c LIKE: searchKey Limit 1000]) {
                if(ac.Customer_Code_SOP__c == Code){
                    accountsList.add(ac);  
                }
            }
        } else {
            for(Account ac : [select ID, Name,Service_Tax_Number__c,Customer_Code_SOP__c,BillingAddress,ShippingAddress,Shipping_Address_Formula__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCOde from Account Where Customer_Code_SOP__c =: Code Limit 1000]) {
                accountsList.add(ac);     
            } 
        }
        System.debug('customerCode-->'+accountsList);
        return accountsList; 
    }
    @AuraEnabled
    public static Void updateOpportunity(string selectedAccount, String recordId) {
        system.debug('selectedAccount'+selectedAccount);
        system.debug('recordId'+recordId);
        list<Opportunity> oppList = New List<Opportunity>();
        Account acc = [select Id,Name,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingCountry,ShippingCity,
                       ShippingCountry,ShippingPostalCode,
                       ShippingState,ShippingStreet,Service_Tax_Number__c,Customer_Code_SOP__c from Account WHERE id =: selectedAccount];
        
        for(Opportunity opp : [select ID,(Select id from OpportunityLineItems), Name,Shipping_City__c,Shipping_Country__c,Shipping_State_Province__c,Shipping_State_Province_Code__c,Shipping_Street__c,Shipping_Zip_Postal_Code__c,Billing_City__c,Billing_Country__c,Billing_State_Province__c, Billing_State_Province_Code__c, Billing_Street__c, Billing_Zip_Postal_Code__c, Shipping_Address__c from Opportunity Where Id =: recordId]) {
            if(opp.OpportunityLineItems.size() > 0){
                //throw all other exception message
                throw new AuraHandledException('Address can not be changed when Product is already addedd to Order');
            }if(Approval.isLocked(opp.Id)){
                //throw all other exception message
                throw new AuraHandledException('You can\'t change address, record is already submited for approval.');
            }
            opp.AccountId = selectedAccount;
            opp.Billing_Street__c = acc.BillingStreet;
            opp.Billing_City__c = acc.BillingCity;
            opp.Billing_State_Province__c = acc.BillingState;
            opp.Billing_Country__c = acc.BillingCountry;
            opp.Billing_Zip_Postal_Code__c = acc.BillingPostalCode ;
            opp.Customer_Code_SHP__c = acc.Service_Tax_Number__c;
            opp.Customer_Code_SOP__c = acc.Customer_Code_SOP__c;
            opp.Shipping_Street__c = acc.ShippingStreet;
            opp.Shipping_City__c = acc.ShippingCity;
            opp.Shipping_Country__c = acc.ShippingCountry;
            opp.Shipping_State_Province__c = acc.ShippingState;
            opp.Shipping_Zip_Postal_Code__c = acc.ShippingPostalCode;
            
            oppList.add(opp);
        }
        Update oppList;
    } 
    
}