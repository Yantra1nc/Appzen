@isTest
public class SOCancelControllerTestClass {
    @isTest
    static void soCancelMethodTestMethod1(){
        
        Opportunity opp1 =new Opportunity();
        opp1.Name='Test Opp 1';
        opp1.StageName='Draft';
        opp1.CloseDate=Date.today() + 10;
        opp1.Brand__c='Layers';
        
        
        try {
            insert opp1;
            system.debug('opp1'+opp1);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        UnicommerceGetSO__c getSoSettings = new UnicommerceGetSO__c();
        getSoSettings.Name = 'GetSalesOrderApi';
        getSoSettings.GetSOApi__c = 'saleOrder/get';
        insert getSoSettings;
        
        UnicommerceCancelSO__c cancelSettings = new UnicommerceCancelSO__c();
        cancelSettings.Name = 'CancelAPI';
        cancelSettings.CancelEndpoint__c = 'oms/saleOrder/cancel';
        insert cancelSettings;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass());
        
        SOCancelController.soCancelMethod(opp1.Id);
        Test.stopTest();
    }
}