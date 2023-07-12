trigger KurlOnUpload on Opportunity (before insert,before update) {
    System.debug('in the trigger');
    KurlOnOpportunityClass.insertOpp(trigger.new);
    public static String token;
    if(Trigger.isUpdate && Trigger.isBefore){       
        for(Opportunity opp:Trigger.new){            
            Opportunity so  = Trigger.oldMap.get(opp.Id);
            if(opp.StageName == 'Submitted for Approval' && so.StageName == 'Draft'){
                System.debug('From Draft to Submitted For Approval');
                System.enqueueJob(new UnicommerceSalesOrderUtility(Trigger.new));                    
            }            
            if(so.StageName == 'Submitted for Approval' && opp.StageName == 'Order Approved'){
                System.enqueueJob(new CancelSalesOrder(opp.Uniware_Internal_SO_No__c,'Cancelled',Trigger.new,'OrderSubmitted'));   
            }
            if(opp.StageName == 'Cancelled' || opp.StageName == 'Order Rejected'){
                System.debug('Order Rejected');              
                System.enqueueJob(new CancelSalesOrder(opp.Uniware_Internal_SO_No__c,'Cancelled',Trigger.new,'OrderRejected'));
            }
            if(opp.StageName == 'Order Approved' && opp.UserProfile__c =='Distributor Approver Level 2' && opp.Order_Type__c == NULL){
                System.debug('Select order type');              
                opp.adderror('Please select Order Type before approving the order');
            }
            
        }
    }
    
}