@isTest
public class Test_ProductCreateUpdate {
    Public static TestMethod void Test_ProductCreateUpdate(){
        Product2 pro = New Product2();
        pro.Name= 'TestProduct';
        insert pro; 
        update pro;
        if(pro.Condition__c == 'FALSE')
        {delete pro; }
    }
}