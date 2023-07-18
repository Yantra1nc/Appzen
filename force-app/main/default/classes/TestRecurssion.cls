@IsTest
public class TestRecurssion {
    
    Public static TestMethod void recurtest(){
        Product2 p = New Product2();
        p.Name = 'testname';
        p.From_NetSuite__c = false;
        insert p;
        Test.startTest();
        NewAvoidRecursion.updateRecord(p);
        Test.stopTest();
    }
}