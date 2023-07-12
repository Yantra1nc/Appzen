@isTest
public class UnicommerceAuthenticationTest {
    @isTest
    public static void testGetToken() { 
        UnicommerceAuthentication__c setting = new UnicommerceAuthentication__c();
        setting.Name = 'AuthEndpointUrl';
        setting.UnicommerceAuthEndpoint__c = 'Test Url value';
        insert setting;
        Test.setMock(HttpCalloutMock.class, new UniAuthHttpMockCallout()); 
        Test.startTest();
        String token = UnicommerceAuthentication.getAuthenticationToken();
        System.assertEquals(token, '11e3a3e9-8892-4f58-9fdd-c8302867285b');
        Test.stopTest();
    }
}