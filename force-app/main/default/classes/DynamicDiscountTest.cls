@isTest
public class DynamicDiscountTest {
    
    @isTest
    public static void testGetProductsDynamicDisc(){
        
        //Arrange
        
        DynamicDiscount.FilterWrapper testWrap = new DynamicDiscount.FilterWrapper();
        testWrap.collection = new String[] {'Firenze'};
        testWrap.minPrice = 100;
        testWrap.maxPrice = 100;
        testWrap.brand = new String[] {'abc'};
        testWrap.designType = new String[] {'Floral'};
        testWrap.size = new String[] {'9'};
        testWrap.color = new String[] {'Red'};
        testWrap.designNo = new String[] {'5100412'};
        testWrap.productType = new String[] {'Dohar'};
                                
                                
        Account acc = new Account();
        acc.Name='Account Test 1';
        //acc.Customer_Code__c = '600055';
        insert acc;
       
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
        
       
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;        
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;

        
        
        // Create Opportunity 
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;        
        
        //Act
        
        Test.startTest();      
        List<Product2> lstPdtDO = DynamicDiscount.getProductsDynamicDisc(testWrap,opp.Id,1);
        Test.stopTest(); 
        
      
    } 
    
    @isTest
    public static void testGetCountOfRecords(){
        
        //Arrange
        
        DynamicDiscount.FilterWrapper testWrap = new DynamicDiscount.FilterWrapper();
        testWrap.collection = new String[] {'Firenze'};
        testWrap.minPrice = 100;
        testWrap.maxPrice = 100;
        testWrap.brand = new String[] {'abc'};
        testWrap.designType = new String[] {'Floral'};
        testWrap.size = new String[] {'9'};
        testWrap.color = new String[] {'Red'};
        testWrap.designNo = new String[] {'5100412'};
        testWrap.productType = new String[] {'Dohar'};
                                
                                
        Account acc = new Account();
        acc.Name='Account Test 1';
        //acc.Customer_Code__c = '600055';
        insert acc;
       
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
        
       
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;        
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;

        
        
        // Create Opportunity 
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;        
        
        //Act
        
        Test.startTest();      
        DynamicDiscount.getCountOfRecords(testWrap,opp.Id);
        Test.stopTest(); 
        
      
    } 
    
    @isTest
    public static void testGetProductDetails(){
        
        //Arrange            
                                
        Account acc = new Account();
        acc.Name='Account Test 1';
        //acc.Customer_Code__c = '600055';
        insert acc;
       
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
        
       
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;        
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;

        
        
        // Create Opportunity 
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;        
        
        //Act
        
        Test.startTest();      
        DynamicDiscount.getProductDetails(opp.Id);
        Test.stopTest(); 
        
      
    } 
    
    @isTest
    public static void testGetProductMrp(){
        
        //Arrange            
                                
        Account acc = new Account();
        acc.Name='Account Test 1';
        //acc.Customer_Code__c = '600055';
        insert acc;
       
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
        
       
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;        
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;

        
        
        // Create Opportunity 
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;        
        
        //Act
        
        Test.startTest();      
        DynamicDiscount.getProductMrp(p1.Id, opp.Id);
        Test.stopTest(); 
        
      
    } 
    
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
        DynamicDiscount.getGST(lstProd, opp.Id, flagTrue);
        DynamicDiscount.getGST(lstProd, opp.Id, flagFalse); 
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
        DynamicDiscount.getGST(lstProd, opp.Id, flagTrue);
        DynamicDiscount.getGST(lstProd, opp.Id, flagFalse); 
        Test.stopTest();
        
    }
        
    @isTest
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
      
        Pricebook2 pb7 = new pricebook2(name='KurlON to Retailer Price',isActive=true);
        insert pb7;
        
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
        opp.Pricebook2Id = pb2.id;
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
        insert opp1;
        opp1.Shipping_State_Province__c='Assam';  
        update opp1;
        
        Opportunity oppQuery = [Select Id,Billing_State_Province__c,Shipping_State_Province__c,Billing_State_Province_Code__c,Shipping_State_Province_Code__c from Opportunity where Within_Maharashtra__c = false limit 1];
        System.debug('Code '+ oppQuery);
        Opportunity testOpp1 = new Opportunity();       
        testOpp1.Name = 'Test opp 1';
        testOpp1.StageName = 'Draft';
        testOpp1.CloseDate = Date.today() + 10;
        testOpp1.Brand__c = 'Layers';
        testOpp1.Billing_State_Province__c = 'Maharashtra';
        //testOpp1.Within_Maharashtra__c = true;
        insert testOpp1;
        
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.Quantity=10;
        oli.UnitPrice=1999;
        oli.Product2Id=testPdt.Id;
        oli.PricebookEntryId=pbe1.Id;
        oli.Indo_Count_Additional_Discount__c=0.2;        
       // insert oli;
        
        OpportunityLineItem oli1=new OpportunityLineItem();
        oli1.OpportunityId=opp1.Id;
        oli1.Quantity=5;
        oli1.UnitPrice=599;
        oli1.Product2Id=testPdt.Id;
        oli1.PricebookEntryId=pbe1.Id;
        oli1.Indo_Count_Additional_Discount__c=0.2;
        //insert oli1;
        
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
        List<DynamicDiscount.OpportunityWrapper> lstWrapper = new List<DynamicDiscount.OpportunityWrapper>();
        DynamicDiscount.OpportunityWrapper oppWrapper =  new DynamicDiscount.OpportunityWrapper();
        oppWrapper.productId = testPdt.Id;
        oppWrapper.opportunityId = opp.Id;
        oppWrapper.kurlonretailprice = 1999.0;
        oppWrapper.finalPrice = 1999.0;
        oppWrapper.additionalDiscountPrice = 10.0;
        oppWrapper.quantity = 10;    
        oppWrapper.oppLineItemId = oli.Id;
        
        lstWrapper.add(oppWrapper);  
        
        //Wrapper with salesorder within state = false
        DynamicDiscount.OpportunityWrapper oppWrapper1 =  new DynamicDiscount.OpportunityWrapper();
        oppWrapper1.productId = testPdt.Id;
        oppWrapper1.opportunityId = opp1.Id;
        oppWrapper1.kurlonretailprice = 599.0;
        oppWrapper1.finalPrice = 599.0;
        oppWrapper1.additionalDiscountPrice = 10.0;
        oppWrapper1.quantity = 10;
        oppWrapper1.oppLineItemId = oli1.Id;
        
        lstWrapper.add(oppWrapper1);  
        
        DynamicDiscount.OpportunityWrapper oppWrapper2 =  new DynamicDiscount.OpportunityWrapper();
        oppWrapper2.productId = testPdt.Id;
        oppWrapper2.opportunityId = opp1.Id;
        oppWrapper2.kurlonretailprice = 599.0;
        oppWrapper2.finalPrice = 599.0;
        oppWrapper2.additionalDiscountPrice = 10.0;
        oppWrapper2.quantity = 10;         
        oppWrapper2.oppLineItemId = null;
        lstWrapper.add(oppWrapper2);
        
        DynamicDiscount.OpportunityWrapper oppWrapper3 =  new DynamicDiscount.OpportunityWrapper();
        oppWrapper3.productId = testPdt.Id;
        oppWrapper3.opportunityId = opp.Id;
        oppWrapper3.kurlonretailprice = 1999.0;
        oppWrapper3.finalPrice = 1999.0;
        oppWrapper3.additionalDiscountPrice = 10.0;
        oppWrapper3.quantity = 10;    
        oppWrapper3.oppLineItemId = null;
        lstWrapper.add(oppWrapper3);
        
        DynamicDiscount.OpportunityWrapper oppWrapper4 =  new DynamicDiscount.OpportunityWrapper();
        oppWrapper4.productId = testPdt.Id;
        oppWrapper4.opportunityId = opp.Id;
        oppWrapper4.kurlonretailprice = 499.0;
        oppWrapper4.finalPrice = 499.0;
        oppWrapper4.additionalDiscountPrice = 10.0;
        oppWrapper4.quantity = 10;    
        oppWrapper4.oppLineItemId = null;
        lstWrapper.add(oppWrapper4);
        
        DynamicDiscount.OpportunityWrapper oppWrapper5 =  new DynamicDiscount.OpportunityWrapper();
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
            DynamicDiscount.saveEditedLineItems(lstWrapper, lstToDelete, opp1.Id);
            //DiscountCalculation.saveEditedLineItems(lstWrapper, lstToDelete, opp.Id);
            
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetOppLineItems(){
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
       
        Pricebook2 pb7 = new pricebook2(name='KurlON to Retailer Price',isActive=true);
        insert pb7;
        
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
        //insert oli;
        
        OpportunityLineItem oli1=new OpportunityLineItem();
        oli1.OpportunityId=opp1.Id;
        oli1.Quantity=5;
        oli1.UnitPrice=599;
        oli1.Product2Id=testPdt.Id;
        oli1.PricebookEntryId=pbe1.Id;
        oli1.Indo_Count_Additional_Discount__c=0.2;
        //insert oli1;
      
        //Act
        
        Test.startTest();
        try{
            DynamicDiscount.getOppLineItems(opp.Id);
            //DiscountCalculation.saveEditedLineItems(lstWrapper, lstToDelete, opp.Id);
            
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void dynamicDiscountLFS(){
        
        Account acc2 = new Account();
        acc2.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc2;
        
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
        p1.Collection__c = 'FIRENZE-2';      
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe6 = new PricebookEntry(pricebook2id= pb1.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe6;
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc2.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;     
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe6.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;      
       // insert oppLineItem;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc2.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Flat__c = false;
        rlg.Distribution_Channel__c = '63';
        rlg.Distribution_No__c = 63;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,opp.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void dynamicDiscountLFS1(){
        
        Account acc2 = new Account();
        acc2.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc2;
        
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
        p1.Collection__c = 'FIRENZE-2';      
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb1 = new pricebook2(name='LFS Price Book',isActive=true);
        insert pb1;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe6 = new PricebookEntry(pricebook2id= pb1.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe6;
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc2.Id;
        opp.Name = 'Test Opportunity LFS';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LFS Sales Order').getRecordTypeId();        
        insert opp;     
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe6.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Product2Id=pbe6.Product2Id;       
        //insert oppLineItem;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc2.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 0;
        pm.MD_Distributor_Margin__c = 0;
        pm.MD_LFS_Margin__c = 0;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 10;
        pm.MU_Distributor_Margin__c= 10;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 10;
        pm.MU_Retailer_GST__c = 10;
        insert pm;  
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Above_1000__c = false;
        rlg.Below_1000__c = true;
        rlg.Flat__c = false;
        rlg.Distribution_Channel__c = '63';
        rlg.Distribution_No__c = 63;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,opp.Id);
        Test.stopTest();
    }

 	@isTest
    public static void dynamicDiscountDistributor(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';      
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
         
        List<Pricebook2>priceLst = new List<Pricebook2>();
        
        Pricebook2 pb4 = new pricebook2(name='Distributor Price Book',isActive=true);
        priceLst.add(pb4);  
        Pricebook2 pb5 = new pricebook2(name='Retailer',isActive=true);
        priceLst.add(pb5);
        Pricebook2 pb6 = new pricebook2(name='Distributor Sales Order',isActive=true);
        priceLst.add(pb6);
        Pricebook2 pb7 = new pricebook2(name='IndoCount to KurlOn Price',isActive=true);
        priceLst.add(pb7);
        insert priceLst;
        
            
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='IndoCount to KurlOn Price' limit 1];
        
        List<PricebookEntry>pbeLst = new List<PricebookEntry>();
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        pbeLst.add(pbe7);  
        PricebookEntry pbe8 = new PricebookEntry(pricebook2id= pb5.Id, product2id=p1.id,unitprice=400.0, isActive=true);
        pbeLst.add(pbe8);
        PricebookEntry pbe9 = new PricebookEntry(pricebook2id= pb6.Id, product2id=p1.id,unitprice=500.0, isActive=true);
        pbeLst.add(pbe9);
        insert pbeLst;
        
        Opportunity oppDist = new Opportunity();       
        oppDist.Brand__c='Layers';
        oppDist.Billing_State_Province__c='Kerala';
        oppDist.Shipping_State_Province__c='Maharashtra';
        oppDist.AccountId = acc.Id;
        oppDist.Name = 'Test Opportunity Distributor';
        oppDist.CloseDate= Date.today() + 10;
        oppDist.StageName='Draft';
        oppDist.CheckUpdateSO__c = true;
        oppDist.Pricebook2Id = pbQuery.Id;
        oppDist.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Distributor Sales Order').getRecordTypeId();       
        insert oppDist;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppDist.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        //sinsert oppLineItemDist;
        
        List<Price_Master__c>pmList = new List<Price_Master__c>();
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'PILLOW';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 1;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        pmList.add(pm);
        
        Price_Master__c pm1 = new Price_Master__c();       
        pm1.Activated_Start_Date__c = Date.today();
        pm1.Activated_End_Date__c = Date.today().addDays(30);
        pm1.Account__c  = acc.Id;
        pm1.Active__c = true;
        pm1.Brand__c  ='All';
        pm1.Collection__c = 'All';
        pm1.Product_Type__c = 'PILLOW';        
        pm1.MD_Disc_Term__c = 10;
        pm1.MD_Distributor_Margin__c = 10;
        pm1.MD_LFS_Margin__c = 10;
        pm1.MD_Retailer_Margin__c = 10;
        pm1.MD_Retailer_GST__c = 10;
        pm1.MU_Discount_Term__c = 0;
        pm1.MU_Distributor_Margin__c= 0;
        pm1.MU_LFS_Margin__c = 0;
        pm1.MU_Retailer_Margin__c = 0;
        pm1.MU_Retailer_GST__c = 0;
        pmList.add(pm1);
        
        Price_Master__c pm2 = new Price_Master__c();       
        pm2.Activated_Start_Date__c = Date.today();
        pm2.Activated_End_Date__c = Date.today().addDays(30);
        pm2.Account__c  = acc.Id;
        pm2.Active__c = true;
        pm2.Brand__c  ='All';
        pm2.Collection__c = 'All';
        pm2.Product_Type__c = 'PILLOW';        
        pm2.MD_Disc_Term__c = 0;
        pm2.MD_Distributor_Margin__c = 0;
        pm2.MD_LFS_Margin__c =0;
        pm2.MD_Retailer_Margin__c = 0;
        pm2.MD_Retailer_GST__c = 0;
        pm2.MU_Discount_Term__c = 10;
        pm2.MU_Distributor_Margin__c= 10;
        pm2.MU_LFS_Margin__c = 10;
        pm2.MU_Retailer_Margin__c = 20;
        pm2.MU_Retailer_GST__c = 20;
        pmList.add(pm2);
        insert pmList;
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Flat__c = true;
        rlg.Distribution_Channel__c = '61';
        rlg.Distribution_No__c = 61;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppDist.Id);
        DynamicDiscount.calculateDiscountDistributor(pm, p1);
        DynamicDiscount.calculateDiscountDistributor(pm, p1);
        DynamicDiscount.calculateDiscountDistributor(pm, p1);
 
        Test.stopTest();
    }   
    
    @isTest
    public static void dynamicDiscountRetailer(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2'; 
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = null;
        pm.MU_Distributor_Margin__c= null;
        pm.MU_LFS_Margin__c = null;
        pm.MU_Retailer_Margin__c = null;
        pm.MU_Retailer_GST__c = null;
        insert pm;  
       
         List<ZRLG__c> lstRlg = new  List<ZRLG__c>();
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        lstRlg.add(rlg);
        
        ZRLG__c rlg2 = new ZRLG__c();
        rlg2.Distribution_No__c = 61;
        rlg2.Above_1000__c = true;
        rlg2.Below_1000__c = false;
        rlg2.Percentage__c = 12;
        rlg2.HSN_CODE__c = '94049099';
        rlg2.Flat__c = true;
        lstRlg.add(rlg2);
        
        insert lstRlg;
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void dynamicDiscountRetailer2(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 0;
        pm.MD_Distributor_Margin__c = 0;
        pm.MD_LFS_Margin__c = 0;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 0;
        pm.MU_Discount_Term__c = 10;
        pm.MU_Distributor_Margin__c= 10;
        pm.MU_LFS_Margin__c = 10;
        pm.MU_Retailer_Margin__c = 10;
        pm.MU_Retailer_GST__c = 10;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 61;
        rlg.Above_1000__c = false;
        rlg.Below_1000__c = true;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = true;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void dynamicDiscountDirect(){
        
        Account acc2 = new Account();
        acc2.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc2;
        
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
        p1.Collection__c = 'FIRENZE-2';      
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb1 = new pricebook2(name='Direct Price Book',isActive=true);
        insert pb1;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe6 = new PricebookEntry(pricebook2id= pb1.Id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe6;
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc2.Id;
        opp.Name = 'Test Opportunity Direct';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Direct Partner').getRecordTypeId();        
        insert opp;     
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe6.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Product2Id=p1.Id;       
        //insert oppLineItem;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc2.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = null;
        pm.MU_Distributor_Margin__c= null;
        pm.MU_LFS_Margin__c = null;
        pm.MU_Retailer_Margin__c = null;
        pm.MU_Retailer_GST__c = null;
        insert pm;  
        
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Flat__c = true;
        rlg.Distribution_Channel__c = '67';
        rlg.Distribution_No__c = 67;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,opp.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void dynamicDiscountDirect2(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 0;
        pm.MD_Distributor_Margin__c = 0;
        pm.MD_LFS_Margin__c = 0;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 0;
        pm.MU_Discount_Term__c = 10;
        pm.MU_Distributor_Margin__c= 10;
        pm.MU_LFS_Margin__c = 10;
        pm.MU_Retailer_Margin__c = 10;
        pm.MU_Retailer_GST__c = 10;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = false;
        rlg.Below_1000__c = true;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest(seeAllData=true)
    public static void dynamicDiscountKurlOn(){
        
        Account acc2 = new Account();
        acc2.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc2;
        
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
        p1.Collection__c = 'FIRENZE-2';
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb1 = new pricebook2(name='IndoCount to KurlOn Price',isActive=true);
        insert pb1;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='KurlON to Retailer Price' limit 1];
        
        PricebookEntry pbe6 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe6;
        
        
        Opportunity opp = new Opportunity();       
        opp.Brand__c='Layers';
        opp.Billing_State_Province__c='Assam';
        opp.Shipping_State_Province__c='Assam';
        opp.AccountId = acc2.Id;
        opp.Name = 'Test Opportunity Direct';
        opp.CloseDate= Date.today() + 10;
        opp.StageName='Draft';
        opp.CheckUpdateSO__c = true;
        opp.Pricebook2Id = pb1.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();        
        insert opp;     
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe6.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Product2Id=p1.Id;       
        insert oppLineItem;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc2.Id;
        pm.Active__c = true;
        pm.Brand__c  ='Layers';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
        
        
        ZRLG__c rlg = new ZRLG__c();
        rlg.Above_1000__c = false;
        rlg.Below_1000__c = false;
        rlg.Flat__c = true;
        rlg.Distribution_Channel__c = '68';
        rlg.Distribution_No__c = 68;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,opp.Id);
        DynamicDiscount.calculateDiscountB2B(pm, p1);
        DynamicDiscount.testmethodx();
        Test.stopTest();
    }    
    
    @isTest
    public static void testFindPriceMasterMethod2(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'FIRENZE-2';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod3(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'PILLOW';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod4(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='Layers';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod5(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='Layers';
        pm.Collection__c = 'FIRENZE-2';
        pm.Product_Type__c = 'All';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod6(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='Layers';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'PILLOW';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod7(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='Layers';
        pm.Collection__c = 'FIRENZE-2';
        pm.Product_Type__c = 'PILLOW';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void testFindPriceMasterMethod8(){
        
        Account acc = new Account();
        acc.Name='Account Test 2';
        //acc.Customer_Code__c = '600055';
        insert acc;
        
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
        p1.Collection__c = 'FIRENZE-2';        
        insert p1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 pb4 = new pricebook2(name='Retailer',isActive=true);
        insert pb4;  
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=p1.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        Pricebook2 pbQuery = [Select Id,Name from Pricebook2 where Name='Retailer'];
        
        PricebookEntry pbe7 = new PricebookEntry(pricebook2id= pbQuery.Id, product2id=p1.id,unitprice=2000.0, isActive=true);
        insert pbe7;
        
        Opportunity oppRet = new Opportunity();       
        oppRet.Brand__c='Layers';
        oppRet.Billing_State_Province__c='Kerala';
        oppRet.Shipping_State_Province__c='Kerala';
        oppRet.AccountId = acc.Id;
        oppRet.Name = 'Test Opportunity Retailer';
        oppRet.CloseDate= Date.today() + 10;
        oppRet.StageName='Draft';
        oppRet.CheckUpdateSO__c = true;
        oppRet.Pricebook2Id = pbQuery.Id;
        oppRet.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();       
        insert oppRet;        
        
        OpportunityLineItem oppLineItemDist = new OpportunityLineItem();
        oppLineItemDist.OpportunityId = oppRet.Id;
        oppLineItemDist.PricebookEntryId = pbe7.Id;
        oppLineItemDist.UnitPrice = 7000;
        oppLineItemDist.Quantity = 5;
        oppLineItemDist.Product2Id=p1.Id;       
        insert oppLineItemDist;
        
        Price_Master__c pm = new Price_Master__c();       
        pm.Activated_Start_Date__c = Date.today();
        pm.Activated_End_Date__c = Date.today().addDays(30);
        pm.Account__c  = acc.Id;
        pm.Active__c = true;
        pm.Brand__c  ='All';
        pm.Collection__c = 'All';
        pm.Product_Type__c = 'PILLOW';        
        pm.MD_Disc_Term__c = 10;
        pm.MD_Distributor_Margin__c = 10;
        pm.MD_LFS_Margin__c = 10;
        pm.MD_Retailer_Margin__c = 0;
        pm.MD_Retailer_GST__c = 10;
        pm.MU_Discount_Term__c = 0;
        pm.MU_Distributor_Margin__c= 0;
        pm.MU_LFS_Margin__c = 0;
        pm.MU_Retailer_Margin__c = 0;
        pm.MU_Retailer_GST__c = 0;
        insert pm;  
       
        ZRLG__c rlg = new ZRLG__c();
        rlg.Distribution_No__c = 62;
        rlg.Above_1000__c = true;
        rlg.Below_1000__c = false;
        rlg.Percentage__c = 12;
        rlg.HSN_CODE__c = '94049099';
        rlg.Flat__c = false;
        insert rlg;
        
        Test.startTest();
        DynamicDiscount.calculateDynamicDiscount(p1.Id,oppRet.Id);
        DynamicDiscount.getOpportunityRecord(oppRet.Id);
        DynamicDiscount.getPriceMaster(p1.Id,oppRet.Id);
        DynamicDiscount.getCollectionsPickList(p1.Id);
        Test.stopTest();
    } 
    
    
    
    
    
}