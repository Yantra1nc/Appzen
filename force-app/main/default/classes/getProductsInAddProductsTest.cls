@isTest(SeeAllData=true)
public class getProductsInAddProductsTest{
    
    @isTest static void testGetProducts(){
       
        //Arrange
        
        getProductsInAddProducts.FilterWrapper testWrap = new getProductsInAddProducts.FilterWrapper();
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
        opp.CheckUpdateSO__c = true;
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
            
        //Act
            
        Test.startTest();    
            
        List<Product2> lstPdt = getProductsInAddProducts.getProducts(testWrap,opp.Id,5);
        Integer count = getProductsInAddProducts.getCountOfRecords(testWrap, opp.Id);
        Product2 pd = getProductsInAddProducts.getProductMrp(p1.Id);
        Opportunity opp1 = getProductsInAddProducts.getProductDetails(opp.Id);
        List<OpportunityLineItem> lstOpp = getProductsInAddProducts.getOppLineItems(opp.Id); 
        getProductsInAddProducts.updateSalesOrder(opp.Id);
        Test.stopTest();        
    
        //Assert
        System.assert(lstPdt.size() == 0);
        System.assert(lstOpp.size() > 0);
        System.assert(pd.Id != null);
        System.assert(opp.Id != null);
    }

}