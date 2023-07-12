public class KurlOnOpportunityClass {
    
    public static void insertOpp(list<Opportunity> opp){
        
        system.debug('in the class');
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        
        Set<String> custcode = new set<String>();
        for(Opportunity op1:opp){
            if(op1.Record_Type_for_Upload__c != null && op1.Record_Type_for_Upload__c == 'KurlON Sales Order'){  
                op1.RecordTypeId = kurlOnId;
            }
            custcode.add(op1.Customer_Code_SHP__c); // added customer code
        }
        system.debug('CUstomer id->'+custcode);
        
        List<Account> acc = [Select id,Customer_Code__c,Name from Account where Customer_Code__c =: custcode];
        System.debug('Account List ->'+acc);
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        List<User> userLst=[SELECT Id, Username, LastName,ProfileId FROM User where Profile.Name ='System Administrator'];
        if(acc.size()>0)
        {
            for(User us:userLst){
                for(Opportunity op:opp){
                    if(op.CreatedById==us.Id){
                        for(Account ac:acc){
                            if(op.Customer_Code_SHP__c==ac.Customer_Code__c){
                                op.AccountId=ac.Id;
                                system.debug('op'+op);
                                system.debug('ac1'+ac);
                            }
                        }
                    }
                }
            }
        }
    }
}