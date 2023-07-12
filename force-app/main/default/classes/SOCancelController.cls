public class SOCancelController {
    @AuraEnabled
    public static String soCancelMethod(Id recordId)
    {
        String status;
        String saleOrderCode;
        System.debug(recordId);
        List<Invoice__c> lstInv = [Select Id,Opportunity__c From Invoice__c where Opportunity__c =:recordId];
        Opportunity opp = [Select Id,Uniware_Internal_SO_No__c from Opportunity where Id=:recordId];
        saleOrderCode = opp.Uniware_Internal_SO_No__c;
        
        if(lstInv.size() > 0){
            status = 'Error';
        }else if(lstInv.size() == 0){
            String token;
            if(!Test.isRunningTest()){
                token = UnicommerceAuthentication.getAuthenticationToken();  
            }
            String res = GetSalesOrder.getSalesOrder(saleOrderCode, token);
            System.debug('status '+res);
            if(res == 'Error'){
                status = 'Error';
            }else if(res == 'Success'){
                
                Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cancelled Order').getRecordTypeId();            
                List<Opportunity> lstOpp= [Select id,StageName,RecordTypeId from Opportunity where Id=:recordId limit 1];
                Approval.UnlockResult[] urList = Approval.unlock(lstOpp, false);
				for(Approval.UnlockResult ur : urList) {
                    if (ur.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                       // System.debug('Successfully unlocked opp with ID: ' + ur.getId());
                        if (lstOpp != NULL)
                        {
                            lstOpp[0].StageName = 'Cancelled';
                            lstOpp[0].RecordTypeId =OppRecordTypeId;
                            update lstOpp[0];
                        }
                        status = 'Success';
                        UnicommerceSalesOrderUtility.cancelSalesOrder(saleOrderCode, 'Cancelled');
                        Approval.lock(lstOpp,false);
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : ur.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Opp fields that affected this error: ' + err.getFields());
                        }
                    }
                } 
               
            }
        }        
        return status;
    }
}