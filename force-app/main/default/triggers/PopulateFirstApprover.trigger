/* This trigger checks the Approver from account and populate on Opp */
trigger PopulateFirstApprover on Opportunity (before insert, before update) {
    System.debug('Inside PopulateFirstApprover');
    Id retailerid=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IndoCount Retailer').getRecordTypeId(); 
    Id distributorid=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Distributor Sales Order').getRecordTypeId(); 
    
    for(Opportunity opp1 : Trigger.new){
        System.debug('Inside for loop');
        
        Opportunity oppacc = [select id,AccountId from Opportunity where id=:opp1.id];
        System.debug('Account id-->'+oppacc.AccountId);
        
        Account acc1 = [select id,Approver_1__c from Account where id=:oppacc.AccountId];
        System.debug('acc1.Approver_1__c id-->'+acc1.Approver_1__c);
        
        Account acc2 = [select id,Approver_2__c from Account where id=:oppacc.AccountId];
        System.debug('acc2.Approver_2__c id-->'+acc2.Approver_2__c);
        
        
        if(opp1.RecordTypeId == retailerid && opp1.Parent_Account__c != null)  {
            System.debug('inside retiler opp1.RecordTypeId->' +opp1.RecordTypeId);
            
            System.debug('inside retiler if opp.Parent_Account__c Retailer' +opp1.Parent_Account__c);
            
           User u1 = [Select id from user where id =:acc1.Approver_1__c];
                   System.debug('user 1 id' +u1.Id);

           User u2 = [Select id from user where id =:acc2.Approver_2__c];
                               System.debug('user 2 id' +u2.Id);
            
            opp1.First_Approver_Name__c = u1.Id;

            opp1.Second_Approver_Name__c = u2.Id;
            
        }
        else if(opp1.RecordTypeId == distributorid && opp1.Parent_Account__c != null)
        {
            System.debug('opp.Parent_Account__c Distributor' +opp1.Parent_Account__c);
            
            User u1 = [Select id from user where id =:acc1.Approver_1__c];
            User u2 = [Select id from user where id =:acc2.Approver_2__c];
            
            opp1.First_Approver_Name__c = u1.Id;
            opp1.Second_Approver_Name__c = u2.Id;
            
        }
    }      //   IndoCount Retailer
    //Distributor Sales Order
    
    
    
}