@isTest
public class DiscountCalculationTest { 
    @isTest
    public static void testGetGSTElse1(){
        Account acc = new Account();
        acc.Name='Test Acc';
        acc.BillingState='Maharashtra';
        acc.ShippingState='Kerala';
        insert acc;
        
        List<ID> lstProd = new List<ID>();
        
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test1';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.Product__c = 'COMFORTER';
        insert testPdt;        
        lstProd.add(testPdt.Id);      
        
        
        GST__c g1=new GST__c();
        g1.Name='Test GST1';
        g1.HSN__c= '94049019';       
        g1.Within_State__c= TRUE;       
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_greater_than_1000__c=0.00;           
        insert g1;
        
        GST__c g2=new GST__c();
        g2.Name='Test GST2';
        g2.HSN__c= '94049019';        
        g2.Within_State__c= FALSE;        
        g2.CGST_less_than_1000__c=6.00;
        g2.CGST_greater_than_1000__c=12.00;
        g2.SGST_less_than_1000__c=6.00;
        g2.SGST_greater_than_1000__c=12.00;
        g2.IGST_less_than_1000__c=0.00;
        g2.IGST_greater_than_1000__c=0.00;
        insert g2;
        
        Boolean flagTrue = true;
        Boolean flagFalse = false;
        
        Opportunity opp =new Opportunity();
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp.Name='Test Opp1';
        opp.StageName='Draft';
        opp.CloseDate=Date.today() + 10;
        opp.Brand__c='Layers';
        opp.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp.AccountId=acc.Id;  
        opp.Billing_State_Province__c = 'Maharashtra';
        opp.Shipping_State_Province__c = 'Kerala';        
        insert opp;
        
        List<Opportunity> oppLstAll=[Select Id,Name,StageName,CloseDate,Brand__c,Record_Type_for_Upload__c,AccountId,
                                     Billing_State_Province__c,Shipping_State_Province__c,
                                     Within_Maharashtra__c,Billing_State_Province_Code__c,Shipping_State_Province_Code__c
                                     From Opportunity where Id=:opp.id];
        
        system.debug('oppLstAll'+oppLstAll);
        
        Test.startTest();
        DiscountCalculation.getGST(lstProd, opp.Id, flagTrue);
        DiscountCalculation.getGST(lstProd, opp.Id, flagFalse); 
        Test.stopTest();
    }
    
    @isTest
    public static void testGetGstIF2(){
        Account acc = new Account();
        acc.Name='Test Acc';
        acc.BillingState='Haryana';
        acc.ShippingState='Haryana';
        insert acc;
        
        List<ID> lstProd = new List<ID>();        
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test1';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.Product__c = 'COMFORTER';
        insert testPdt;        
        lstProd.add(testPdt.Id);    
        
        Opportunity opp =new Opportunity();
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp.Name='Test Opp1';
        opp.StageName='Draft';
        opp.CloseDate=Date.today() + 10;
        opp.Brand__c='Layers';
        opp.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp.AccountId=acc.Id;  
        opp.Billing_State_Province__c = 'Haryana';
        opp.Shipping_State_Province__c = 'Haryana';        
        insert opp;
        
        GST__c g1=new GST__c();
        g1.Name='Test GST1';
        g1.HSN__c= '94049019';       
        g1.Within_State__c= TRUE;       
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_greater_than_1000__c=0.00;           
        insert g1;
        
        GST__c g2=new GST__c();
        g2.Name='Test GST2';
        g2.HSN__c= '94049019';        
        g2.Within_State__c= FALSE;        
        g2.CGST_less_than_1000__c=6.00;
        g2.CGST_greater_than_1000__c=12.00;
        g2.SGST_less_than_1000__c=6.00;
        g2.SGST_greater_than_1000__c=12.00;
        g2.IGST_less_than_1000__c=0.00;
        g2.IGST_greater_than_1000__c=0.00;
        insert g2;
        
        List<Opportunity> oppLstAll=[Select Id,Name,StageName,CloseDate,Brand__c,Record_Type_for_Upload__c,AccountId,
                                     Billing_State_Province__c,Shipping_State_Province__c,
                                     Within_Maharashtra__c,Billing_State_Province_Code__c,Shipping_State_Province_Code__c
                                     From Opportunity where Id=:opp.id];
        
        Boolean flagTrue = true;
        Boolean flagFalse = false;
        
        Test.startTest();
        DiscountCalculation.getGST(lstProd, opp.Id, flagTrue);
        DiscountCalculation.getGST(lstProd, opp.Id, flagFalse); 
        Test.stopTest();
        
    }
    
    @isTest(SeeAllData=True)
    public static void testSaveLineItems(){
        //Arrange     
        
        Account acc = new Account();
        acc.Name='Test Acc';
        insert acc;
        
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.Product__c = 'COMFORTER';
        //testPdt.HSN_Code__c = '94049019';
        insert testPdt; 
        
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=testPdt.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id= pb2.Id, product2id=testPdt.id,unitprice=2.0, isActive=true);
        insert pbe1;
        
        Opportunity opp =new Opportunity();
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp.Name='Test Opp';
        opp.StageName='Draft';
        opp.CloseDate=Date.today() + 10;
        opp.Brand__c='Layers';
        opp.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp.AccountId=acc.Id;  
        opp.Billing_State_Province__c='Maharashtra';
        opp.Shipping_State_Province__c='Maharashtra';
        insert opp;
        
        Opportunity opp1 =new Opportunity();
        Id kurlOnId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp1.Name='Test Opp1';
        opp1.StageName='Draft';
        opp1.CloseDate=Date.today() + 10;
        opp1.Brand__c='Layers';
        opp1.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp1.AccountId=acc.Id;  
        opp1.Billing_State_Province__c='Maharashtra';
        opp1.Shipping_State_Province__c='Delhi';
        insert opp1;
        
        Opportunity testOpp1 = new Opportunity();       
        testOpp1.Name = 'Test opp 1';
        testOpp1.StageName = 'Draft';
        testOpp1.CloseDate = Date.today() + 10;
        testOpp1.Brand__c = 'Layers';
        //testOpp1.Within_Maharashtra__c = true;
        insert testOpp1;
        
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.Quantity=10;
        oli.UnitPrice=1999;
        oli.Product2Id=testPdt.Id;
        oli.PricebookEntryId=pbe1.Id;
        oli.Indo_Count_Additional_Discount__c=0.2;        
        insert oli;
        
        List<GST__c> lstGst =new List<GST__c>();
        GST__c g1=new GST__c();
        g1.Name='Test GST1';
        g1.HSN__c= '94049019';
        System.debug('HSNCODE'+testPdt.HSN_Code__c);
        g1.Within_State__c= TRUE;
        System.debug(opp.Within_Maharashtra__c);
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_greater_than_1000__c=0.00;
        lstGst.add(g1);        
        insert lstGst;
        
        GST__c g2=new GST__c();
        g2.Name='Test GST2';
        g2.HSN__c= '94049019';        
        g2.Within_State__c= FALSE;        
        g2.CGST_less_than_1000__c=6.00;
        g2.CGST_greater_than_1000__c=6.00;
        g2.SGST_less_than_1000__c=6.00;
        g2.SGST_greater_than_1000__c=6.00;
        g2.IGST_less_than_1000__c=0.00;
        g2.IGST_greater_than_1000__c=0.00;
        insert g2;
        
        //Wrapper with salesorder within state = true
        List<DiscountCalculation.OpportunityWrapper> lstWrapper = new List<DiscountCalculation.OpportunityWrapper>();
        DiscountCalculation.OpportunityWrapper oppWrapper =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper.productId = testPdt.Id;
        oppWrapper.opportunityId = opp.Id;
        oppWrapper.kurlonretailprice = 1999.0;
        oppWrapper.finalPrice = 1999.0;
        oppWrapper.additionalDiscountPrice = 10.0;
        oppWrapper.quantity = 10;      
        oppWrapper.oppLineItemId = oli.Id;        
        lstWrapper.add(oppWrapper);  
        
        //Wrapper with salesorder within state = false
        DiscountCalculation.OpportunityWrapper oppWrapper1 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper1.productId = testPdt.Id;
        oppWrapper1.opportunityId = opp1.Id;
        oppWrapper1.kurlonretailprice = 599.0;
        oppWrapper1.finalPrice = 599.0;
        oppWrapper1.additionalDiscountPrice = 10.0;
        oppWrapper1.quantity = 10;       
        oppWrapper1.oppLineItemId = oli.Id;        
        lstWrapper.add(oppWrapper1);  
        
        DiscountCalculation.OpportunityWrapper oppWrapper2 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper2.productId = testPdt.Id;
        oppWrapper2.opportunityId = opp.Id;
        oppWrapper2.kurlonretailprice = 599.0;
        oppWrapper2.finalPrice = 599.0;
        oppWrapper2.additionalDiscountPrice = 10.0;
        oppWrapper2.quantity = 10;      
        oppWrapper2.oppLineItemId = oli.Id;        
        lstWrapper.add(oppWrapper2);  
        
        DiscountCalculation.OpportunityWrapper oppWrapper3 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper3.productId = testPdt.Id;
        oppWrapper3.opportunityId = opp1.Id;
        oppWrapper3.kurlonretailprice = 1599.0;
        oppWrapper3.finalPrice = 1599.0;
        oppWrapper3.additionalDiscountPrice = 10.0;
        oppWrapper3.quantity = 10;       
        oppWrapper3.oppLineItemId = oli.Id;        
        lstWrapper.add(oppWrapper3);  
        
        
        //Act
        
        Test.startTest();
        try{
            DiscountCalculation.saveLineItems(lstWrapper);
        }catch(Exception e){
            System.debug('Exception '+ e);
        }        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=True)
    public static void testSaveEditedItems(){
        Account acc = new Account();
        acc.Name='Test Acc';
        insert acc;
        
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.Product__c = 'COMFORTER';
        //testPdt.HSN_Code__c = '94049019';
        insert testPdt; 
        
        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
        //System.debug('PricebId'+pb2.Id);
        
        Pricebook2 pb = new pricebook2(name='Test Pb',isActive=true);
        insert pb;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=testPdt.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=pb2.Id,product2id=testPdt.id,unitprice=2.0, isActive=true);        
        insert pbe1;
        
        
        
        Opportunity opp =new Opportunity();
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp.Name='Test Opp';
        opp.StageName='Draft';
        opp.CloseDate=Date.today() + 10;
        opp.Brand__c='Layers';
        opp.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp.AccountId=acc.Id;  
        opp.Billing_State_Province__c='Maharashtra';
        opp.Shipping_State_Province__c='Maharashtra';
        insert opp;
        
        Opportunity opp1 =new Opportunity();
        Id kurlOnId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        opp1.Name='Test Opp1';
        opp1.StageName='Draft';
        opp1.CloseDate=Date.today() + 10;
        opp1.Brand__c='Layers';
        opp1.Record_Type_for_Upload__c = 'KurlON Sales Order';    
        opp1.AccountId=acc.Id;  
        opp1.Billing_State_Province__c='Maharashtra';
        opp1.Shipping_State_Province__c='Kerala';
        //testOpp1.Within_Maharashtra__c = true;

        insert opp1;
        
        Opportunity testOpp1 = new Opportunity();       
        testOpp1.Name = 'Test opp 1';
        testOpp1.StageName = 'Draft';
        testOpp1.CloseDate = Date.today() + 10;
        testOpp1.Brand__c = 'Layers';
        //testOpp1.Within_Maharashtra__c = true;
        insert testOpp1;
        
        List<OpportunityLineItem>oliLst = new List<OpportunityLineItem>();
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.Quantity=10;
        oli.UnitPrice=1999;
        oli.Product2Id=testPdt.Id;
        oli.PricebookEntryId=pbe1.Id;
        oli.Indo_Count_Additional_Discount__c=0.2;        
        oliLst.add(oli);
        
        OpportunityLineItem oli1=new OpportunityLineItem();
        oli1.OpportunityId=opp1.Id;
        oli1.Quantity=5;
        oli1.UnitPrice=599;
        oli1.Product2Id=testPdt.Id;
        oli1.PricebookEntryId=pbe1.Id;
        oli1.Indo_Count_Additional_Discount__c=0.2;
        oliLst.add(oli1);
        
        insert oliLst;
        
        List<GST__c> lstGst =new List<GST__c>();
        GST__c g1=new GST__c();
        g1.Name='Test GST1';
        g1.HSN__c= '94049019';        
        g1.Within_State__c= TRUE;        
        g1.CGST_less_than_1000__c=6.00;
        g1.CGST_greater_than_1000__c=6.00;
        g1.SGST_less_than_1000__c=6.00;
        g1.SGST_greater_than_1000__c=6.00;
        g1.IGST_less_than_1000__c=0.00;
        g1.IGST_greater_than_1000__c=0.00;
        lstGst.add(g1);        
        insert lstGst;
        
        GST__c g2=new GST__c();
        g2.Name='Test GST2';
        g2.HSN__c= '94049019';        
        g2.Within_State__c= FALSE;        
        g2.CGST_less_than_1000__c=6.00;
        g2.CGST_greater_than_1000__c=6.00;
        g2.SGST_less_than_1000__c=6.00;
        g2.SGST_greater_than_1000__c=6.00;
        g2.IGST_less_than_1000__c=0.00;
        g2.IGST_greater_than_1000__c=0.00;
        insert g2;
        
        //Wrapper with salesorder within state = true
        List<DiscountCalculation.OpportunityWrapper> lstWrapper = new List<DiscountCalculation.OpportunityWrapper>();
        DiscountCalculation.OpportunityWrapper oppWrapper =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper.productId = testPdt.Id;
        oppWrapper.opportunityId = opp.Id;
        oppWrapper.kurlonretailprice = 1999.0;
        oppWrapper.finalPrice = 1999.0;
        oppWrapper.additionalDiscountPrice = 10.0;
        oppWrapper.quantity = 10;    
        oppWrapper.oppLineItemId = oli.Id;
        
        lstWrapper.add(oppWrapper);  
        
        //Wrapper with salesorder within state = false
        DiscountCalculation.OpportunityWrapper oppWrapper1 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper1.productId = testPdt.Id;
        oppWrapper1.opportunityId = opp1.Id;
        oppWrapper1.kurlonretailprice = 599.0;
        oppWrapper1.finalPrice = 599.0;
        oppWrapper1.additionalDiscountPrice = 10.0;
        oppWrapper1.quantity = 10;
        oppWrapper1.oppLineItemId = oli1.Id;
        
        lstWrapper.add(oppWrapper1);  
        
        DiscountCalculation.OpportunityWrapper oppWrapper2 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper2.productId = testPdt.Id;
        oppWrapper2.opportunityId = opp1.Id;
        oppWrapper2.kurlonretailprice = 599.0;
        oppWrapper2.finalPrice = 599.0;
        oppWrapper2.additionalDiscountPrice = 10.0;
        oppWrapper2.quantity = 10;         
        oppWrapper2.oppLineItemId = null;
        lstWrapper.add(oppWrapper2);
        
        DiscountCalculation.OpportunityWrapper oppWrapper3 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper3.productId = testPdt.Id;
        oppWrapper3.opportunityId = opp.Id;
        oppWrapper3.kurlonretailprice = 1999.0;
        oppWrapper3.finalPrice = 1999.0;
        oppWrapper3.additionalDiscountPrice = 10.0;
        oppWrapper3.quantity = 10;    
        oppWrapper3.oppLineItemId = null;
        lstWrapper.add(oppWrapper3);
        
        DiscountCalculation.OpportunityWrapper oppWrapper4 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper4.productId = testPdt.Id;
        oppWrapper4.opportunityId = opp.Id;
        oppWrapper4.kurlonretailprice = 499.0;
        oppWrapper4.finalPrice = 499.0;
        oppWrapper4.additionalDiscountPrice = 10.0;
        oppWrapper4.quantity = 10;    
        oppWrapper4.oppLineItemId = null;
        lstWrapper.add(oppWrapper4);
        
        DiscountCalculation.OpportunityWrapper oppWrapper5 =  new DiscountCalculation.OpportunityWrapper();
        oppWrapper5.productId = testPdt.Id;
        oppWrapper5.opportunityId = opp1.Id;
        oppWrapper5.kurlonretailprice = 1499.0;
        oppWrapper5.finalPrice = 1499.0;
        oppWrapper5.additionalDiscountPrice = 10.0;
        oppWrapper5.quantity = 10;    
        oppWrapper5.oppLineItemId = null;
        lstWrapper.add(oppWrapper5);
        
        List<Id> lstToDelete = new List<Id>();
        lstToDelete.add(oli.Id);
        //Act
        
        Test.startTest();
        try{
            DiscountCalculation.saveEditedLineItems(lstWrapper, lstToDelete, opp1.Id);
            //DiscountCalculation.saveEditedLineItems(lstWrapper, lstToDelete, opp.Id);
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        Test.stopTest();
    }
    
    
}