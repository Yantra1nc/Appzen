/***********
* @group : indocount project
* @since : Jun-2022
* @Description : Apex test class to cover Uniware API test classes
* @auther : YANTRA DEV
* ****/
@isTest 
public class UnicommerceExportJobProductsTest {
    /******
* @description : test setup method to create test data
* *******/
    @testSetup static void setup() {
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
        
        //create test records here
        
        Product2 p1=new Product2();
        p1.Name='Test Product 1';
        p1.Brand__c='Layers';
        p1.IsActive=true;
        p1.Standard_Price__c=500;
        //increase Indo_Count_to_Kurl_On_Price__c price for else condition
        p1.Indo_Count_to_Kurl_On_Price__c=60;
        p1.Kurl_On_to_Retailer_Price__c=700;
        p1.MOP__c='800';
        p1.Product__c='PILLOW';
        p1.Material_Number__c = '12345';
        insert p1;
        
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.Product__c = 'COMFORTER';
        insert testPdt; 
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=testPdt.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=pb.Id,product2id=testPdt.id,unitprice=2.0, isActive=true);        
        insert pbe1;
        
        //create account test
        Account acc = new Account();
        acc.Name='Account Test 1';
        acc.BillingStreet = 'Tesyds';
        acc.BillingCity = 'wwerwe';
        acc.BillingState = 'Alaska';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '1231231';
        acc.ShippingStreet = 'Tesyds';
        acc.ShippingCity = 'wwerwe';
        acc.ShippingState = 'Alaska';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '1231231';
        insert acc;
        
        //create account test
        Account parent2 = new Account();
        parent2.Name='Account Test 1';
        parent2.BillingStreet = 'Tesyds';
        parent2.BillingCity = 'wwerwe';
        parent2.BillingState = 'Alaska';
        parent2.BillingCountry = 'United States';
        parent2.BillingPostalCode = '1231231';
        parent2.ShippingStreet = 'Tesyds';
        parent2.ShippingCity = 'wwerwe';
        parent2.ShippingState = 'Alaska';
        parent2.ShippingCountry = 'United States';
        parent2.ShippingPostalCode = '1231231';
        parent2.Customer_Code__c = 'Same';
        insert parent2;        
        //create account test
        Account parent = new Account();
        parent.Name='Account Test 1';
        parent.BillingStreet = 'Tesyds';
        parent.BillingCity = 'wwerwe';
        parent.BillingState = 'Alaska';
        parent.BillingCountry = 'United States';
        parent.BillingPostalCode = '1231231';
        parent.ShippingStreet = 'Tesyds';
        parent.ShippingCity = 'wwerwe';
        parent.ShippingState = 'Alaska';
        parent.ShippingCountry = 'United States';
        parent.ShippingPostalCode = '1231231';
        parent.Customer_Code__c = 'Picklist Code';
        //acc.Customer_Code__c = '600055';
        insert parent;
        
        
        // Creatig Opp for test record
        List<Opportunity>oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.accountId = acc.Id;
        opp.Name='Sample Opp';
        opp.StageName='Draft';
        opp.Brand__c = 'Boutique Living	';
        opp.CloseDate=date.today().addDays(+7);
        opp.Uniware_Internal_SO_No__c = 'ACDZCVP_1232123';
        opp.OrderNumUniware__c = 'ONU-1234';
        oppList.add(opp);
        
        Opportunity opp2 = new Opportunity();
        opp2.accountId = acc.Id;
        opp2.Name='Sample Opp';
        opp2.StageName='Draft';
        opp2.Brand__c = 'Boutique Living';
        opp2.OrderNumUniware__c = 'ONU-1232';
        opp2.CloseDate=date.today().addDays(+7);
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.accountId = acc.Id;
        opp3.Name='Sample Opp';
        opp3.StageName='Draft';
        opp3.Brand__c = 'Boutique Living	';
        opp3.CloseDate=date.today().addDays(+7);
        opp3.Uniware_Internal_SO_No__c = '_1232123';
        oppList.add(opp3);
        
        Opportunity opp4 = new Opportunity();
        opp4.accountId = acc.Id;
        opp4.Name='Sample Opp';
        opp4.StageName='Draft';
        opp4.Brand__c = 'Boutique Living	';
        opp4.CloseDate=date.today().addDays(+7);
        opp4.Uniware_Internal_SO_No__c = '1232123';
        oppList.add(opp4);
        
        insert oppList;
        
        Invoice__c inv1 = new Invoice__c();
        inv1.Opportunity__c = oppList[0].Id;
        inv1.Order_No_Uniware__c = '_1232123';
        inv1.Invoice_No__c = 'Order2';
        inv1.Invoice_Created_Date__c = DateTime.now();
        inv1.Shipping_Package_Code__c = 'Order22'; 
        insert inv1;
        
        Invoice__c inv2 = new Invoice__c();
        inv2.Opportunity__c = oppList[0].Id;
        inv2.Order_No_Uniware__c = '1232123';
        inv2.Invoice_No__c = 'Order2';
        inv2.Invoice_Created_Date__c = DateTime.now();
        inv2.Shipping_Package_Code__c = 'Order22'; 
        insert inv2;
        
        List<OpportunityLineItem>olilst = new List<OpportunityLineItem>();
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.Quantity=10;
        oli.UnitPrice=1999;
        oli.Product2Id=testPdt.Id;
        oli.PricebookEntryId=pbe1.Id;
        oli.Indo_Count_Additional_Discount__c=0.2;        
        olilst.add(oli);
        
        OpportunityLineItem oli1=new OpportunityLineItem();
        oli1.OpportunityId=opp4.Id;
        oli1.Quantity=2;
        oli1.UnitPrice=599;
        oli1.Product2Id=testPdt.Id;
        oli1.PricebookEntryId=pbe1.Id;
        oli1.Indo_Count_Additional_Discount__c=0.2;
        olilst.add(oli1);
        
        insert olilst;
    }
    @isTest
    public static void UnicommerceExportJobTestMethod(){
        //set mock for api
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass());
        
        //create enqueue instance
        UnicommerceExportJob uncExp = new UnicommerceExportJob();
        System.enqueueJob(uncExp);
    }
    @isTest
    public static void UnicommerceExportJobStatusTestMethod(){
        //set mock for api
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass());
        
        UnicommerceExportJobStatus uncExpStat = new UnicommerceExportJobStatus('ABCDSXZJNSC');
        System.enqueueJob(uncExpStat);
    }
    @isTest
    public static void UnicommerceExportJobProductsTestMethod(){
        //set mock for api
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass());
        
        UnicommerceGetExportCsv uncExpStat = new UnicommerceGetExportCsv('test/test/test');
        System.enqueueJob(uncExpStat);
        System.enqueueJob(new UnicommerceExportJobProducts());
        UnicommerceExportJobProducts.createExportJob();
    }
    @isTest
    public static void UnicommerceProductDetailsBatchTestMethod(){
        String token = '12345678987654';
        List<String> lstSkuCodesNew = new List<String>{'test'};
            //set mock for api
            Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass());
        
        String jobId = database.executeBatch(new UnicommerceProductDetailsBatch(token,lstSkuCodesNew), 80);        
    }
    
    //test 2nd scenario 2 mock
    public class batchTestMock Implements HttpCalloutMock {
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            String reqEndpoint = req.getEndpoint();
            String reqMethod = req.getMethod();
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if(String.isNotBlank(reqEndpoint) && reqEndpoint.containsIgnoreCase('v1/catalog/itemType/get')  && String.isNotBlank(reqMethod) && reqMethod.containsIgnoreCase('POST')){
                res.setBody('{"successful":true,"message":null,"errors":[],"warnings":null,"itemTypeDTO":{"tat":null,"id":158626,"skuCode":"12345","categoryCode":"KFL_163_30049099","name":"test","description":"","scanIdentifier":"1234","length":1,"width":1,"height":1,"weight":1,"color":null,"size":null,"brand":null,"ean":"qwqwe","upc":"","isbn":"","maxRetailPrice":1000,"basePrice":150,"batchGroupCode":"ABCD","costPrice":120,"taxTypeCode":null,"gstTaxTypeCode":"DEFAULT_GST","hsnCode":"1212123","imageUrl":"asdasdasdasdas/asdasd/asda","productPageUrl":"asdasdasdasdas/asdasd/asda","type":"SIMPLE","scanType":"SIMPLE","determineExpiryFrom":null,"taxCalculationType":null,"requiresCustomization":false,"itemDetailFieldsText":"","enabled":true,"tags":[],"shelfLife":null,"expirable":false,"customFieldValues":[{"fieldName":"Woollen","fieldValue":"","valueType":"text","displayName":"Wollen","required":false}],"componentItemTypes":[],"grnExpiryTolerance":null,"dispatchExpiryTolerance":null,"returnExpiryTolerance":null,"minOrderSize":1,"expiryDate":null}}');
            }
            return res;
            
        }
    }
    
    @isTest
    public static void batchTestMockMethod(){
        String token = '12345678987654';
        List<String> lstSkuCodesNew = new List<String>{'12345'};
            //set mock for api
            Test.setMock(HttpCalloutMock.class, new batchTestMock());
        String jobId = database.executeBatch(new UnicommerceProductDetailsBatch(token,lstSkuCodesNew), 80);        
    }
    @isTest
    public static void UnicommerceGetInventorySnapshotTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceGetInventorySnapshot clsInv = new UnicommerceGetInventorySnapshot();
        System.schedule('jobName', '0 0 0 ? * * *', clsInv);
        UnicommerceGetInventorySnapshot.getInventorySnapshot('asdasdasdasdasdas', 'inventory/inventorySnapshot/get', new Set<String>{'12345'});
    } 
    @isTest
    public static void UnicommerceCustomerMasterTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceCustomerMaster clsCus = new UnicommerceCustomerMaster();
        UnicommerceCustomerMaster.createExportJobCustomerMaster();
    } 
    
    @isTest
    public static void UnicommerceCustomerMasterExportStatusTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceCustomerMasterExportStatus clsCus = new UnicommerceCustomerMasterExportStatus('123456yfg','23456tfghh');
        System.enqueueJob(clsCus);
        System.schedule('UnicommerceCustomerMaster222', '0 0 0 ? * * *', new UnicommerceCustomerMaster());
    }  
    
    @isTest
    public static void UnicommerceSalesOrderUtilityTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        
        UnicommerceSalesOrderUtility clsCus = new UnicommerceSalesOrderUtility();
        UnicommerceSalesOrderUtility clsCus2 = new UnicommerceSalesOrderUtility([select id,Distrbution_Channel__c,Header_Status__c,Order_Type__c,Shipping_Address__c,AccountId,Uniware_Internal_SO_No__c,Sales_Order_No__c,StageName from Opportunity]);
        UnicommerceSalesOrderUtility.cancelSalesOrder('saleOrderCode', 'cancellationReason');
        UnicommerceSalesOrderUtility.getSalesOrder('asdasdasd', 'asdasdasdasdas');
        
        System.enqueueJob(clsCus2);
        
    } 
    
    @isTest
    public static void UnicommerceInvoiceExportJobTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceInvoiceExportJob clsCus = new UnicommerceInvoiceExportJob();
        System.schedule('UnicommerceCustomerMaster11', '0 0 0 ? * * *', clsCus);
        UnicommerceInvoiceExportJob.createExportJobInvoice();
    } 
    
    //test invoice file path mock
    public class GetInvoiceMock Implements HttpCalloutMock {
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            String reqEndpoint = req.getEndpoint();
            String reqMethod = req.getMethod();
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if(String.isNotBlank(reqEndpoint) && reqEndpoint.containsIgnoreCase('export/job/status')  && String.isNotBlank(reqMethod) && reqMethod.containsIgnoreCase('POST')){
                res.setBody('{"filePath":"inv/inv/inv","successful": true, "status": "COMPLETE","code":"101","description":"abcd test","message":"test msg"}');
            }if(String.isNotBlank(reqEndpoint) && reqEndpoint.containsIgnoreCase('inv/inv/inv')  && String.isNotBlank(reqMethod) && reqMethod.containsIgnoreCase('GET')){
                res.setBody('Order_No__c,Invoice_No__c,Invoice_Created_Date__c,Shipping_Package_Code__c,skuCode,quantity,invoiceTax,Amount_Due__c,cgst,igst,sgst,utgst,cgstrate,igstrate,sgstrate,utgstrate,tcsAmount\n_1232123,INVN-1231231,'+Date.today()+',SPC-31222,1000,0239,23423,23423,54232,123,12312,12312,12313,343,454,565,09239\n1232123,INVN-123122,'+Date.today()+',SPC-31222,2000,0239,23423,23423,54232,123,12312,12312,12313,343,454,565,09239');
            }
            return res;
            
        }
    }
    
    @isTest
    public static void UnicommerceInvoiceExportStatusTest(){
        Test.setMock(HttpCalloutMock.class, new GetInvoiceMock()); 
        UnicommerceInvoiceExportStatus clsCus = new UnicommerceInvoiceExportStatus('asdasdasdasdasda','123123dqwfwdaasd');
        System.enqueueJob(clsCus);
    } 
    
    @isTest
    public static void UniwareUpdateSalesOrderTest(){
        Test.setMock(HttpCalloutMock.class, new GetInvoiceMock()); 
        UniwareUpdateSalesOrder clsCus = new UniwareUpdateSalesOrder([select id,Uniware_Internal_SO_No__c from Opportunity where Uniware_Internal_SO_No__c != null]);
        System.enqueueJob(clsCus);
    }
    @isTest
    public static void CancelSalesOrderTest(){
        Test.setMock(HttpCalloutMock.class, new GetInvoiceMock()); 
        CancelSalesOrder clsCus = new CancelSalesOrder('saleOrderCode','cancellationReason',[select id from Opportunity],'');
        System.enqueueJob(clsCus);
    } 
    @isTest
    public static void UnicommerceProductDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceProductDetails clsCus = new UnicommerceProductDetails(new Set<String> {'F51563'});
        System.enqueueJob(clsCus);
    } 
    @isTest
    public static void UnicommerceExportJobProductsTest(){
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceSearchProducts clsCus = new UnicommerceSearchProducts();
        System.enqueueJob(clsCus);
        UnicommerceSearchProducts.getSearchItems();
    } 
}