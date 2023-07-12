@isTest
public class ProductServiceTest {
    //test to check whether the products queried is not null
    @isTest static void testGetProducts(){
        
        //Insert product
        Product2 testPdt = new Product2();
        testPdt.Name = 'Test';
        testPdt.Design_Type__c = 'Test';
        testPdt.Product_Image_Link__c = 'Test url';
        testPdt.Brand__c = 'ABC';
        testPdt.Size__c = '8';
        testPdt.Color__c = 'Red';
        testPdt.Collection__c = 'Sample';
        testPdt.IsActive = true;
        insert testPdt; 
        
        
        Product2 testPdt1 = new Product2();
        testPdt1.Name = 'Product2';
        testPdt1.Design_Type__c = 'Floral';       
        testPdt1.Brand__c = 'abc';
        testPdt1.Size__c = '9';
        testPdt1.Color__c = 'Red';
        testPdt1.Collection__c = 'Firenze';
        testPdt1.IsActive = true;
        insert testPdt1; 
        
        //Create a standard pricebook
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        //Insert pricebook
        Pricebook2 pb = new pricebook2(name='KurlON to Retailer Price');
        insert pb;
        
        //Insert pricebookentry
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=testPdt.id,unitprice=4999.0, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=testPdt1.id,unitprice=499.0, isActive=true);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id = pb.Id, product2id=testPdt1.id,unitprice=499.0, isActive=true);
        insert pbe2;
        
        
        //Insert a wrapper with no results
        ProductService.FilterWrapper testWrap = new ProductService.FilterWrapper();
        testWrap.collection = new String[] {'Firenze'};
        testWrap.minPrice = 100;
        testWrap.maxPrice = 100;
        testWrap.brand = new String[] {'abc'};
            testWrap.designType = new String[] {'Floral'};
                testWrap.size = new String[] {'9'};
                    testWrap.color = new String[] {'Red'};
                        testWrap.designNo = new String[] {'5100412'};
                            testWrap.prodType = new String[] {'Dohar'};                               
        
        
        ProductService.FilterWrapper testWrap1 = new ProductService.FilterWrapper();
        //testWrap1.collection = new String[] {'Firenze'};
        //testWrap1.minPrice = 100;
        //testWrap1.maxPrice = 599;
        //testWrap1.brand = new String[] {'abc'};
            //testWrap1.designType = new String[] {'Floral'};
                //testWrap1.size = new String[] {'9'};
                    testWrap1.color = new String[] {'Red'};
                        //testWrap1.designNo = new String[] {'5100412'};
                           // testWrap1.prodType = new String[] {'Dohar'};
                                
                                
        Test.startTest();
        List<Product2> lstPdt = ProductService.getProducts(testWrap);
        //Check for no filter results
        System.assertEquals(0, lstPdt.size());        
       // List<Product2> lstPdt1 = ProductService.getProducts(testWrap1);
              
        Test.stopTest();
    }
    
}