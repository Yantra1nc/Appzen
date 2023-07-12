@isTest
public class CheckTestDataUtility {
    
    Public testmethod static void check(){
        // Below is the sample code for test data creation from TestDataUtility Class.
        Lead intialLead=TestDataUtility.createLead(True);
        Account acc=TestDataUtility.createAccount(True);
        Contact c=TestDataUtility.createContact(True);
        Opportunity o=TestDataUtility.createOpportunity(True);
        Case cs=TestDataUtility.createCase(true);
        Product2 p=TestDataUtility.createProduct2(true);
        PricebookEntry v=TestDataUtility.createPricebook2(True);
        OpportunityLineItem oli=TestDataUtility.createOpportunityLineItem(true);
        GST__c gst=TestDataUtility.createGST(true);
    }
}