public class RefreshSalesOrder {
 @auraEnabled
    public static void refreshSalesOrderMethod(Id recordId)
    {
        OpportunityLineItem op1 = new OpportunityLineItem();
      //  op1 = [Select id,Name,(Select Id,OpportunityId,PageLoad__c from OpportunityLineItems) from Opportunity where Id=:OpportunityId];
       op1 = [Select Id,OpportunityId,PageLoad__c from OpportunityLineItem where OpportunityId=:recordId];
        If (op1 != NULL)
        {
           op1.PageLoad__c = FALSE;
            update op1;
        }
    }
}