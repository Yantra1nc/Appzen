trigger NetSuiteOpportunityTrigger on Opportunity (after update) {
    Boolean fireTrigger=true;
    set<id> accIds=new set<id>();
    Map<Id,Account> accounts = new Map<Id,Account>();
    
    for (Opportunity opp: Trigger.new) {
        Opportunity oldOpp=trigger.oldMap.get(opp.Id);
        if(opp.StageName =='Closed Won' && oldOpp.StageName =='Closed Won' && !Test.isRunningTest()){
            fireTrigger=false;
        }
        accIds.add(opp.accountId);
    }
    
    List<Account> accList=[select Id, Atlan_Entity__c,Accounts_Payable_Email__c from account where Id IN :accIds];
    
    for (Opportunity opp: Trigger.new) {
        for(account a:accList){
            system.debug('Account Id==>'+a.Id);
            if(opp.StageName =='Closed Won'){
                a.Atlan_Entity__c= opp.Atlan_Entity__c;
                a.Accounts_Payable_Email__c = opp.Accounts_Payable_Email__c;  
                accounts.put(a.id,a);
            }
        }
    }
    if(!accounts.values().isEmpty() && accounts.values()!=Null){
        update accounts.values();
        system.debug(accounts);
        system.debug(fireTrigger);
        if(!System.isFuture() && !System.isBatch() && !NSSyncUtilityV2.avoidRecurssion && fireTrigger){
            {
                NSSyncUtilityV2.newSyncDataWithNetSuite(trigger.new, 'Opportunity');
            }
        } 
        
    }
    else{
        if(!NSSyncCommanUtility.avoidRecurssion &&!System.isFuture() && !System.isBatch() && fireTrigger){
            if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
                NSSyncCommanUtility.newSyncDataWithNetSuite(trigger.new, 'Opportunity');
            }
        }
    }
}