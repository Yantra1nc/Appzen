/*This Trigger is to check the duplicate Price master active for any given Date Range */
trigger DuplicateProduct on Price_Master__c (before insert, before update) {
    
    for (Price_Master__c pm : Trigger.new) {  
        if(pm.Account__c != null && pm.Product__c != null){
        
        List <Price_Master__c> lst = [SELECT id, Activated_Start_Date__c, Activated_End_Date__c From Price_Master__c where id!=:pm.Id and
                                     ((Activated_Start_Date__c <=:pm.Activated_Start_Date__c AND Activated_End_Date__c >=:pm.Activated_End_Date__c) or
                                     (Activated_Start_Date__c >=:pm.Activated_Start_Date__c AND Activated_End_Date__c <=:pm.Activated_End_Date__c) or
                                      (Activated_Start_Date__c =:pm.Activated_Start_Date__c AND Activated_End_Date__c =:pm.Activated_End_Date__c))
                                     and Product__c=:pm.Product__c and Account__c=:pm.Account__c]; 
        
        if (lst.size() > 0) {
            System.debug('lst.size() '+lst.size());
            pm.adderror( 'There is Price Master Already present with a product between this given date range' );
        } 
        }        
    }
}