@IsTest
public class Test_DeleteJsonLog { 
    Public Static TestMethod Void DeleteJson(){
       JSON_Log__c jlog = New JSON_Log__c();
       jlog.Name ='loghere';
       //jlog.Log_Age__c = 40;  
       Test.startTest();
       insert jlog;
       delete jlog;
       Test.stopTest();
    }

}