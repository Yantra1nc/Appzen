@isTest(seeAllData=true)
public class KurlOnOpportunityLineItemClassTest {
    
    static testmethod void  IndocountGstIfTest1(){
        //if condition
        Account acc = new Account();
        acc.Name='Account Test 1';
        insert acc;
        
        GST__c g1=new GST__c();
        g1.Name='Test GST 1';
        g1.HSN__c='94049099';
        g1.Within_State__c=true;
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_less_than_1000__c=0.00;
        
        insert g1;
        
        // insert product
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
        insert p1;
        
        
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id= pb2.Id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe1;
        
        
        
        // Create Opportunity
        Opportunity opp = new Opportunity();
        
        
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        //opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe1.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Product2Id=p1.Id;
        
        insert oppLineItem;
        system.debug('oppLineItem'+oppLineItem);
        
        List<OpportunityLineItem> oliLst=new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
        oppLineItem2.OpportunityId = opp.Id;
        oppLineItem2.PricebookEntryId = pbe1.Id;
        oppLineItem2.UnitPrice = 7000;
        oppLineItem2.Quantity = 5;
        oppLineItem2.Product2Id=p1.Id;
        
        oliLst.add(oppLineItem2);
        
        insert oliLst;
        system.debug('oppLineItem'+oliLst);
        Test.startTest();
        KurlOnOpportunityLineItemClass kOli1=new KurlOnOpportunityLineItemClass();
        kOli1.PageLoadTrgHandler(oliLst);
        Test.stopTest();
        
        
    }
    static testmethod void  IndocountGstIFElseTest2(){
        //if condition
        Account acc = new Account();
        acc.Name='Account Test 1';
        insert acc;
        
        
        GST__c g1=new GST__c();
        g1.Name='Test GST 1';
        g1.HSN__c='94049099';
        g1.Within_State__c=true;
        
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_less_than_1000__c=0.00;
        
        insert g1;
        
        
        
        
        // insert product
        Product2 p1=new Product2();
        p1.Name='Test Product 1';
        p1.Brand__c='Layers';
        p1.IsActive=true;
        p1.Standard_Price__c=500;
        //increase Indo_Count_to_Kurl_On_Price__c price for else condition
        p1.Indo_Count_to_Kurl_On_Price__c=50000;
        p1.Kurl_On_to_Retailer_Price__c=700;
        p1.MOP__c='800';
        p1.Product__c='PILLOW';
        insert p1;
        
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id= pb2.Id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe1;
        
        
        // Create Opportunity
        Opportunity opp = new Opportunity();
        
        
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        //opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe1.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Product2Id=p1.Id;
        
        insert oppLineItem;
        system.debug('oppLineItem'+oppLineItem);
        
    }
    static testmethod void  MethodForDataInsert5(){
        //if condition
        Account acc = new Account();
        acc.Name='Account Test 1';
        insert acc;
        
        GST__c g1=new GST__c();
        g1.Name='Test GST 1';
        g1.HSN__c='94049099';
        g1.Within_State__c=true;
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_less_than_1000__c=0.00;
        
        insert g1;
        
        // insert product
        Product2 p1=new Product2();
        p1.Name='product1';
        p1.Brand__c='Layers';
        p1.IsActive=true;
        p1.Standard_Price__c=500;
        //increase Indo_Count_to_Kurl_On_Price__c price for else condition
        p1.Indo_Count_to_Kurl_On_Price__c=60;
        p1.Kurl_On_to_Retailer_Price__c=700;
        p1.MOP__c='800';
        p1.Product__c='PILLOW';
        insert p1;
        
        
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id= pb2.Id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe1;
        
        
        
        // Create Opportunity
        Opportunity opp = new Opportunity();
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp.Name='opptest1';
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.RecordTypeId=kurlOnId;
        insert opp;
        
        List<OpportunityLineItem> oliLst=new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
        oppLineItem2.OpportunityId = opp.Id;
        oppLineItem2.PricebookEntryId = pbe1.Id;
        oppLineItem2.UnitPrice = 700;
        oppLineItem2.Additional_Discount__c=0.2;
        oppLineItem2.Quantity = 5;
        oppLineItem2.Sales_Order_Name__c='opptest1';
        oppLineItem2.Product_Name_for_Insert__c='product1';
        oppLineItem2.PricebookEntry_for_Insert__c='product1';
        
        
        oliLst.add(oppLineItem2);
        
        insert oliLst;
        system.debug('oppLineItem'+oliLst);
        Test.startTest();
        KurlOnOpportunityLineItemClass kOli1=new KurlOnOpportunityLineItemClass();
        Test.stopTest();
        
        
    }
    
}