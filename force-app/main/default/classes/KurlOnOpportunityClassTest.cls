@isTest
public class KurlOnOpportunityClassTest {
    
    @isTest
    static void testForOpportunity1(){
         //custom setting records 
        UnicommerceAuthentication__c custSettings = new UnicommerceAuthentication__c(Name = 'AuthEndpointUrl',UnicommerceAuthEndpoint__c = 'https://demostaging.unicommerce.com/oauth/token');
        insert custSettings;
        
        UnicommerceExportJob__c expJob = new UnicommerceExportJob__c(Name = 'ExportJobApi',ExportJob__c = 'https://demostaging.unicommerce.com/services/export/job/create');
        insert expJob;
        
        UnicommerceExportJobStatus__c expStat = new UnicommerceExportJobStatus__c(Name = 'JobStatusUrl',ExportJobStatus__c = 'https://demostaging.unicommerce.com/services/rest/v1/export/job/status');
        insert expStat;
        
        UnicommerceInventory__c inv = new UnicommerceInventory__c(Name = 'UCInventorySnapshot',UCInventorySnapshot__c = 'services/rest/v1/inventory/inventorySnapshot/get');
        insert inv;
        
        UnicommerceCreateSO__c createSo = new UnicommerceCreateSO__c(Name = 'CreateSO',CreateOrder__c = 'rest/v1/oms/saleOrder/create');
        insert createSo;
        
        UnicommerceGetSO__c getSoSettings = new UnicommerceGetSO__c(Name = 'GetSalesOrderApi',GetSOApi__c = 'rest/v1/oms/saleorder/get');
        insert getSoSettings;
        
        UnicommerceCancelSO__c cancelSettings = new UnicommerceCancelSO__c(Name = 'CancelAPI',CancelEndpoint__c = 'rest/v1/oms/saleorder/cancel');
        insert cancelSettings;
        
        UniwareUpdateSO__c UniwareUpdateSO = new UniwareUpdateSO__c (Name = 'UniwareUpdateSO',UpdateOrderEndpoint__c = 'saleOrder/editSaleOrderMetadata');
        Insert UniwareUpdateSO;
        
        
        Account acc1 = new Account();
        acc1.Name='Account Test 1';
        acc1.BillingStreet = 'Tesyds';
        acc1.BillingCity = 'wwerwe';
        acc1.BillingState = 'Alaska';
        acc1.BillingCountry = 'United States';
        acc1.BillingPostalCode = '1231231';
        acc1.ShippingStreet = 'Tesyds';
        acc1.ShippingCity = 'wwerwe';
        acc1.ShippingState = 'Alaska';
        acc1.ShippingCountry = 'United States';
        acc1.ShippingPostalCode = '1231231';
        insert acc1;
        
        List <Opportunity> OppLst1=new List <Opportunity>();
        for(Integer i=0;i<50;i++){
            Opportunity opp1 =new Opportunity();
            opp1.Name='Test Opp'+i;
            opp1.StageName='Draft';
            opp1.CloseDate=Date.today() + 30;
            opp1.Brand__c='Layers';
            opp1.Record_Type_for_Upload__c = 'Kurl On';    
            opp1.AccountId=acc1.Id;
            OppLst1.add(opp1);
        }
        insert OppLst1;
        System.assertEquals(50, OppLst1.size());
        system.assertNotEquals(60, OppLst1.size());
        
        KurlOnOpportunityClass.insertOpp(OppLst1);
        system.debug('OppLst1'+OppLst1);
        OppLst1[0].StageName = 'Submitted for Approval';
        OppLst1[2].StageName = 'Order Rejected';
        OppLst1[1].StageName = 'Order Approved';
        update OppLst1;
        OppLst1[0].StageName = 'Submitted for Approval';
        OppLst1[2].StageName = 'Submitted for Approval';
        OppLst1[1].StageName = 'Submitted for Approval';
        update OppLst1;        
    }
}