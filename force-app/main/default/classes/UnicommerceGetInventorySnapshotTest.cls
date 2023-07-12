@isTest
public class UnicommerceGetInventorySnapshotTest {
	 @isTest
    public static void testGetInventory() { 
        UnicommerceInventory__c setting = new UnicommerceInventory__c();
        setting.Name = 'Test Inventory Endpoint';
        setting.UCInventorySnapshot__c = 'Test Url value';
        insert setting;
        UnicommerceAuthentication__c auth = new UnicommerceAuthentication__c(Name = 'AuthEndpointUrl',UnicommerceAuthEndpoint__c = 'https://demostaging.unicommerce.com/oauth/token');
        insert auth;

        Set<String> setMaterialNo = new Set<String>();
        
        Product2 prod1 = new Product2( Name='Test Product 1',Brand__c='Layers',IsActive=true,Standard_Price__c=500,
        Indo_Count_to_Kurl_On_Price__c=60,Kurl_On_to_Retailer_Price__c=700,MOP__c='800',Product__c='PILLOW',Material_Number__c = 'F31193');
        insert prod1;
        setMaterialNo.add(prod1.Material_Number__c);
        
        Product2 prod2 = new Product2( Name='Test Product 2',Brand__c='Layers',IsActive=true,Standard_Price__c=500,
        Indo_Count_to_Kurl_On_Price__c=60,Kurl_On_to_Retailer_Price__c=700,MOP__c='800',Product__c='PILLOW',Material_Number__c = 'F31192');
        insert prod2;
         setMaterialNo.add(prod2.Material_Number__c);              
        
        String token = '11e3a3e9-8892-4f58-9fdd-c8302867285b';
        UnicommerceInventory__c custSettings = new UnicommerceInventory__c(Name = 'UCInventorySnapshot',UCInventorySnapshot__c = 'services/rest/v1/inventory/inventorySnapshot/get');
        insert custSettings;
        String endPoint = custSettings.UCInventorySnapshot__c;
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new UnicommerceMockTestClass()); 
        UnicommerceGetInventorySnapshot clsInv = new UnicommerceGetInventorySnapshot();
        System.schedule('jobName', '0 0 0 ? * * *', clsInv);
        UnicommerceGetInventorySnapshot.getInventorySnapshot(token, endPoint, setMaterialNo);
        Test.stopTest();
    }
}