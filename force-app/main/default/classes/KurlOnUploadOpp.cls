public class KurlOnUploadOpp {
    
    public void insertOpp(list<Opportunity> opp){
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        Set<String> custcode = new set<String>();
        Map<Id,Account> AccMap = new Map<Id,Account>();
        Set<id> accidset = new Set<Id>();
        Account ac2;
        Set<Id> accid = new set<Id>();
        
        for(Opportunity op1:opp){
            if(op1.Record_Type_for_Upload__c != null && op1.Record_Type_for_Upload__c == 'Kurl On')
            {  op1.RecordTypeId = kurlOnId;}
            
            custcode.add(op1.Customer_Code_SHP__c); // added customer code
            system.debug('CUstomer id->'+custcode);
            
            List<Account> acc = [Select id,Customer_Code__c,Name from Account where Customer_Code__c =: custcode];
            
            for(Account ac1:acc){
                AccMap.put(ac1.id,ac1);
                accidset.add(ac1.id);
                ac2= AccMap.put(ac1.id,ac1);
                System.debug('Account Map->' +AccMap);
                System.debug('Account Variable->' +ac2);
            }
        }
        for(Opportunity op2:opp)
        {
            for(Account ac3:AccMap.values())
            {
                op2.AccountId =ac3.id;
            }
        }
    }
    
    public void populateFirstApprover(list<Opportunity> opportunityList){
        System.debug('Inside PopulateFirstApprover');
        Id kurlonid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('KurlON_Sales_Order').getRecordTypeId(); 
        for(Opportunity opp : opportunityList){
            if(opp.RecordTypeId == kurlonid && opp.Parent_Account__c != null)  {
                System.debug('opp.Parent_Account__c' +opp.Parent_Account__c);
                List<Contact> cons = [Select id, name, email, AccountId from Contact where AccountId =:opp.Parent_Account__c ORDER BY CREATEDDATE DESC LIMIT 1];
                for(Contact con : cons){
                    System.debug('Account Id '+con.AccountId);
                    System.debug('con.name '+con.Name);
                    if(con!=null){
                        User u = [Select id, contact.id from user where contact.id =:con.Id LIMIT 1];
                        opp.First_Approver_Name__c = u.Id;
                    }
                }
            }      
        }
    }
}