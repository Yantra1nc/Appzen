@isTest
public class OppotunityTriggerNetsuit_Test {
    
    public static testmethod void testmethod1(){
        Test.setMock(HttpCalloutMock.class, new MockWebserviceClass_Test());
        
        Netsuite_OAuth__c OAuthDetails = new Netsuite_OAuth__c(Customer_Key__c='ba28e9ed233457ea67c31250089a19e7bb2f209063e73809bce2e0818d86bc5c',
                                                               Customer_Secret__c='697c476691af67b351efb9f578c55c0d1e0a7b612fa0b1ee27a0947476b46b3e',
                                                               Realm__c='TSTDRV1384668',
                                                               Signature_Method__c='HMAC-SHA1',
                                                               Token__c='1ea90d1e0a5a8566a505aec93fc715a4bcf79518af95790b4dc5db541b49e12b',
                                                               Token_Secret__c='578a055c1d2e82cc381b9b3b9e82c3fba338afa8feac4aab60648aa2840de702',
                                                               End_Point_URL__c='https://rest.netsuite.com/app/site/hosting/restlet.nl');
        Insert OAuthDetails;
        SObject_Mapping__c sm1 = new SObject_Mapping__c(name='Opportunity',isActive__c=true,
                                                        JSON_Sobject_Name__c='Sales Order',
                                                        End_Point_URL__c='?script=1124&deploy=1');
        SObject_Mapping__c sm2 = new SObject_Mapping__c(name='Account',isActive__c=true,
                                                        JSON_Sobject_Name__c='Customer',
                                                        End_Point_URL__c='?script=1124&deploy=1');
        Insert sm2;
        Insert sm1;
        Field_Mapping__c fm3 = new Field_Mapping__c(Field_Type__c='Text',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Name',SFDC_Field_API_Name__c='Name',
                                                    SObject_Mapping__c=sm2.Id);
        Insert fm3;
        
        Field_Mapping__c fm1 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Type',SFDC_Field_API_Name__c='Type',
                                                    SObject_Mapping__c=sm1.Id);
        Insert fm1;
        Field_Mapping__c fm2 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='StageName',SFDC_Field_API_Name__c='StageName',
                                                    SObject_Mapping__c=sm1.Id);
        
        Insert fm2;
        Mapping_Condition__c mc = new Mapping_Condition__c(Field_API_Name__c = 'StageName',Value__c='Closed Won',SObject__c=sm1.id);
        Insert mc;
        Opportunity o = new Opportunity(name='Test',closeDate=date.today(),stageName='Closed Won',Contract_Signed_Date__c=date.today());
        Insert o;
        Product2 prod2 = new Product2(
            Name = 'testName',
            IsActive=true);
        insert prod2;
        
        PricebookEntry price = new PricebookEntry(
            UseStandardPrice = false,
            Pricebook2Id = test.getStandardPricebookId(),
            UnitPrice = 1.0,
            IsActive = true,
            Product2Id = prod2.Id);
        insert price;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityId = o.Id,quantity=2,unitprice=20,PricebookEntryId =price.id );
        Insert oli;
    }
    
    public static testmethod void testmethod2(){
        Test.setMock(HttpCalloutMock.class, new MockWebserviceClass_Test());
        Netsuite_OAuth__c OAuthDetails = new Netsuite_OAuth__c(Customer_Key__c='ba28e9ed233457ea67c31250089a19e7bb2f209063e73809bce2e0818d86bc5c',
                                                               Customer_Secret__c='697c476691af67b351efb9f578c55c0d1e0a7b612fa0b1ee27a0947476b46b3e',
                                                               Realm__c='TSTDRV1384668',
                                                               Signature_Method__c='HMAC-SHA1',
                                                               Token__c='1ea90d1e0a5a8566a505aec93fc715a4bcf79518af95790b4dc5db541b49e12b',
                                                               Token_Secret__c='578a055c1d2e82cc381b9b3b9e82c3fba338afa8feac4aab60648aa2840de702',
                                                               End_Point_URL__c='https://rest.netsuite.com/app/site/hosting/restlet.nl');
        Insert OAuthDetails;
        Account a1 = new Account(name='TEst',BillingStreet='Test',BillingCity='NY',BillingState='New York',
                                 Billingpostalcode='322',BillingCountry='United States',
                                 Atlan_Entity__c= 'United States',Accounts_Payable_Email__c='nida@yantrainc.com',                                 
                                 ShippingStreet='Test',ShippingCity='NY',ShippingState='New York',
                                 Shippingpostalcode='322',ShippingCountry='United States');
        Insert a1;
        SObject_Mapping__c sm1 = new SObject_Mapping__c(name='Opportunity',isActive__c=true,
                                                        JSON_Sobject_Name__c='Sales Order',
                                                        End_Point_URL__c='?script=1124&deploy=1');
        Insert sm1;
        
        SObject_Mapping__c sm2 = new SObject_Mapping__c(name='Account',isActive__c=true,
                                                        JSON_Sobject_Name__c='Customer',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Include_Billing_Address__c= true,
                                                        Include_Shipping_Address__c = true);
        Insert sm2;
        Field_Mapping__c fm3 = new Field_Mapping__c(Field_Type__c='Text',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Name',SFDC_Field_API_Name__c='Name',
                                                    SObject_Mapping__c=sm2.Id);
        Insert fm3;
        
        Field_Mapping__c fm1 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Type',SFDC_Field_API_Name__c='Type',
                                                    SObject_Mapping__c=sm1.Id);
        Insert fm1;
        Field_Mapping__c fm2 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='StageName',SFDC_Field_API_Name__c='StageName',
                                                    SObject_Mapping__c=sm1.Id);
        
        Insert fm2;
        Mapping_Condition__c mc = new Mapping_Condition__c(Field_API_Name__c = 'StageName',Value__c='Closed Won',SObject__c=sm1.id);
        Insert mc;
        Opportunity o = new Opportunity(name='Test',closeDate=date.today(),stageName='Closed Won',Contract_Signed_Date__c=date.today(),
                                        accountId=a1.Id);
        Insert o;
        Product2 prod2 = new Product2(
            Name = 'testName',
            IsActive=true);
        insert prod2;
        
        PricebookEntry price = new PricebookEntry(
            UseStandardPrice = false,
            Pricebook2Id = test.getStandardPricebookId(),
            UnitPrice = 1.0,
            IsActive = true,
            Product2Id = prod2.Id);
        insert price;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityId = o.Id,quantity=2,unitprice=20,PricebookEntryId =price.id );
        Insert oli;
        
        contact c1 = new contact(lastname='Test');
        Insert c1;
        OpportunityContactRole  ocr1 = new OpportunityContactRole(ContactId=c1.Id,OpportunityId=o.Id,Role='Other');
        Insert ocr1;
        
        SObject_Mapping__c sm3 = new SObject_Mapping__c(name='OpportunityLineItem',isActive__c=true,
                                                        JSON_Sobject_Name__c='OpportunityLineItem',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Relationship_with_parent__c='OpportunityId',
                                                        Relationship_Type__c='Child',Parent_SObject_Map__c=sm1.ID);
        Insert sm3;
        Field_Mapping__c fm4 = new Field_Mapping__c(Field_Type__c='Number',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='rate',SFDC_Field_API_Name__c='UnitPrice',
                                                    SObject_Mapping__c=sm3.Id);
        Insert fm4;
        
        SObject_Mapping__c sm4 = new SObject_Mapping__c(name='OpportunityContactRole',isActive__c=true,
                                                        JSON_Sobject_Name__c='OpportunityContactRole',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Relationship_with_parent__c='OpportunityId',
                                                        Relationship_Type__c='Child',Parent_SObject_Map__c=sm1.ID);
        Insert sm4;
        
        
        Field_Mapping__c fm5 = new Field_Mapping__c(Field_Type__c='Reference',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='lastname',SFDC_Field_API_Name__c='contact.LastName',
                                                    SObject_Mapping__c=sm4.Id);
        Insert fm5;
        NSSyncCommanUtility.avoidRecurssion = false;
        NSSyncUtilityV2.avoidRecurssion = false;
        List<Opportunity> lstOpportunity = [Select Id,name,StageName,CloseDate from opportunity];
        lstOpportunity.get(0).name = 'testing update';
        Update lstOpportunity;
    }
    
    
    public static testmethod void testmethod3(){
        Test.setMock(HttpCalloutMock.class, new MockWebserviceClass_Test());
        Netsuite_OAuth__c OAuthDetails = new Netsuite_OAuth__c(Customer_Key__c='ba28e9ed233457ea67c31250089a19e7bb2f209063e73809bce2e0818d86bc5c',
                                                               Customer_Secret__c='697c476691af67b351efb9f578c55c0d1e0a7b612fa0b1ee27a0947476b46b3e',
                                                               Realm__c='TSTDRV1384668',
                                                               Signature_Method__c='HMAC-SHA1',
                                                               Token__c='1ea90d1e0a5a8566a505aec93fc715a4bcf79518af95790b4dc5db541b49e12b',
                                                               Token_Secret__c='578a055c1d2e82cc381b9b3b9e82c3fba338afa8feac4aab60648aa2840de702',
                                                               End_Point_URL__c='https://rest.netsuite.com/app/site/hosting/restlet.nl');
        Insert OAuthDetails;
        Account a1 = new Account(name='TEst',BillingStreet='Test',BillingCity='NY',BillingState='New York',
                                 Billingpostalcode='322',BillingCountry='United States',
                                 Atlan_Entity__c= 'United States',Accounts_Payable_Email__c='nida@yantrainc.com',                                 
                                 ShippingStreet='Test',ShippingCity='NY',ShippingState='New York',
                                 Shippingpostalcode='322',ShippingCountry='United States');
        Insert a1;
        SObject_Mapping__c sm1 = new SObject_Mapping__c(name='Opportunity',isActive__c=true,
                                                        JSON_Sobject_Name__c='Sales Order',
                                                        End_Point_URL__c='?script=1124&deploy=1');
        Insert sm1;
        
        SObject_Mapping__c sm2 = new SObject_Mapping__c(name='Account',isActive__c=true,
                                                        JSON_Sobject_Name__c='Customer',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Include_Billing_Address__c= true,
                                                        Include_Shipping_Address__c = true);
        Insert sm2;
        Field_Mapping__c fm3 = new Field_Mapping__c(Field_Type__c='Text',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Name',SFDC_Field_API_Name__c='Name',
                                                    SObject_Mapping__c=sm2.Id);
        Insert fm3;
        
        Field_Mapping__c fm1 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='Type',SFDC_Field_API_Name__c='Type',
                                                    SObject_Mapping__c=sm1.Id);
        Insert fm1;
        Field_Mapping__c fm2 = new Field_Mapping__c(Field_Type__c='Picklist',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='StageName',SFDC_Field_API_Name__c='StageName',
                                                    SObject_Mapping__c=sm1.Id);
        
        Insert fm2;
        Mapping_Condition__c mc = new Mapping_Condition__c(Field_API_Name__c = 'StageName',Value__c='Closed Won',SObject__c=sm1.id);
        Insert mc;
        
        Opportunity o = new Opportunity(name='Test',closeDate=date.today(),stageName='Business Value',Atlan_Entity__c='India',
                                        Accounts_Payable_Email__c='test@gmail.com', accountId=a1.Id);
        Insert o;
        Product2 prod2 = new Product2(
            Name = 'testName',
            IsActive=true);
        insert prod2;
        
        PricebookEntry price = new PricebookEntry(
            UseStandardPrice = false,
            Pricebook2Id = test.getStandardPricebookId(),
            UnitPrice = 1.0,
            IsActive = true,
            Product2Id = prod2.Id);
        insert price;
        
        OpportunityLineItem oli = new OpportunityLineItem(opportunityId = o.Id,quantity=2,unitprice=20,PricebookEntryId =price.id );
        Insert oli;
        
        contact c1 = new contact(lastname='Test');
        Insert c1;
        OpportunityContactRole  ocr1 = new OpportunityContactRole(ContactId=c1.Id,OpportunityId=o.Id,Role='Other');
        Insert ocr1;
        
        SObject_Mapping__c sm3 = new SObject_Mapping__c(name='OpportunityLineItem',isActive__c=true,
                                                        JSON_Sobject_Name__c='OpportunityLineItem',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Relationship_with_parent__c='OpportunityId',
                                                        Relationship_Type__c='Child',Parent_SObject_Map__c=sm1.ID);
        Insert sm3;
        Field_Mapping__c fm4 = new Field_Mapping__c(Field_Type__c='Number',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='rate',SFDC_Field_API_Name__c='UnitPrice',
                                                    SObject_Mapping__c=sm3.Id);
        Insert fm4;
        
        SObject_Mapping__c sm4 = new SObject_Mapping__c(name='OpportunityContactRole',isActive__c=true,
                                                        JSON_Sobject_Name__c='OpportunityContactRole',
                                                        End_Point_URL__c='?script=1124&deploy=1',
                                                        Relationship_with_parent__c='OpportunityId',
                                                        Relationship_Type__c='Child',Parent_SObject_Map__c=sm1.ID);
        Insert sm4;
        
        
        Field_Mapping__c fm5 = new Field_Mapping__c(Field_Type__c='Reference',isActive__c=true,
                                                    NetSuite_Field_API_Name__c='lastname',SFDC_Field_API_Name__c='contact.LastName',
                                                    SObject_Mapping__c=sm4.Id);
        Insert fm5;
        NSSyncCommanUtility.avoidRecurssion = false;
        NSSyncUtilityV2.avoidRecurssion = false;
        List<Opportunity> lstOpportunity = [Select Id,name,StageName,CloseDate from opportunity];
        lstOpportunity.get(0).name = 'testing update';
        Update lstOpportunity;
    }
    
    public static testmethod void testmethod4(){
        Account a1 = new Account(name='TEst',BillingStreet='Test',BillingCity='NY',BillingState='New York',
                                 Billingpostalcode='322',BillingCountry='United States',AnnualRevenue=10,
                                 Atlan_Entity__c= 'United States',Accounts_Payable_Email__c='nida@yantrainc.com',                                 
                                 ShippingStreet='Test',ShippingCity='NY',ShippingState='New York',
                                 Shippingpostalcode='322',ShippingCountry='United States');
        insert a1;
       
        
        Contact c1 = new Contact (FirstName='test', LastName='test2', MailingStreet='Test',MailingCity='NY',MailingState='New York',
                                 MailingPostalCode='322',MailingCountry='United States',OtherStreet='Test',OtherCity='NY',otherState='New York',
                                 OtherPostalCode='322',OtherCountry='United States');

		String addressType = 'Billing';   
        String addressType2 = 'Shipping';
        String addressType3 = 'Other';
        String addressType4 = 'Mailing';
        NSSyncCommanUtility.serializeAddress(a1, addressType);
        NSSyncCommanUtility.serializeAddress(a1, addressType2);
        NSSyncCommanUtility.serializeAddress(c1, addressType3);
        NSSyncCommanUtility.serializeAddress(c1, addressType4);
        NSSyncCommanUtility.serializeField(a1,'BillingStreet','BillingStreet','Checkbox');
        NSSyncCommanUtility.serializeField(a1,'BillingStreet','BillingStreet','Date');
        NSSyncCommanUtility.serializeField(a1,'AnnualRevenue','AnnualRevenue','Number');
        NSSyncCommanUtility.serializeField(a1,'BillingStreet','BillingStreet','Phone');
        NSSyncCommanUtility.serializeField(a1,'BillingStreet','BillingStreet','test');
    }
    
}