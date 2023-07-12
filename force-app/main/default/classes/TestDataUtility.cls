@isTest
public class TestDataUtility {
    
    /** 
    * ********************************************************
    * This method is test data for create Lead
    * ********************************************************
    */

    public static Lead createLead(Boolean doInsert)
    {
        Lead newLead = new Lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'contacted';
        
        if(doInsert){
            insert newLead;
        }
        return newLead;
    }

    public static void convertLead(Lead newLead)
    {
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        lc.setOpportunityName('Cole Swain');
        
    }
        
    /** 
    * ******************************************************
    * This method is test data for create Account
    * ******************************************************
    */
    
    public static Account createAccount(Boolean doInsert)
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        if(doInsert){
            insert acc;
        }
        return acc;
    }
       
     /**
     * *******************************************************
     * This method is test data for create contact object
     * *******************************************************
     */
    public static Contact createContact(Boolean doInsert)
    {
        return createContact(doInsert, createAccount(true).Id);
    }
    
    public static Contact createContact(Boolean doInsert, Id accId)
    {
        Contact con = new Contact();
        con.AccountId = accId;
        con.FirstName = 'FirstName';
        con.LastName = 'LastName';
        con.Email = 'FirstName@test.com' + Math.floor(Math.random() * 1000);
        if(doInsert)
        {
            insert con;
        }
        return con;
    }

    /**
    * ***********************************************************
    * This method is test data for create Opportunity object
    * ***********************************************************
    */
    public static Opportunity createOpportunity(Boolean doInsert)
    {
        return createOpportunity(doInsert, createAccount(true).Id);
    }
    public static Opportunity createOpportunity(Boolean doInsert, Id accId)
    {
        Opportunity oppt = new Opportunity(Name ='New mAWS Deal',
                            AccountID = accId,
                            Amount = 3000,
                            StageName='Draft',
                            CloseDate=Date.today() + 30,
                            Brand__c='Layers',
                            Record_Type_for_Upload__c = 'Kurl On');
        if(doInsert)
        {
            insert oppt;
        }
        return oppt;
    }   
    
    
    
    /**
    * ************************************************************
    * This method is test data for create Case object
    * ************************************************************
    */
        
    public static Case  createCase(Boolean doInsert)
    {
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email');
        if(doInsert)
        {
            insert cas ;
        }
        return cas ;
    }    
    
    /**
    * ************************************************************
    * This method is test data for create Product2 object
    * ************************************************************
    */
        
    public static Product2 createProduct2(Boolean doInsert)
    {
        Product2 prod2 = new Product2( Name='Test Product 1',Brand__c='Layers',IsActive=true,Standard_Price__c=500,
        Indo_Count_to_Kurl_On_Price__c=60,Kurl_On_to_Retailer_Price__c=700,MOP__c='800',Product__c='PILLOW');
        if(doInsert)
        {
            insert prod2 ;
        }
        return prod2 ;
    }   
    
    /**
    * ************************************************************
    * This method is test data for create Pricebook object
    * ************************************************************
    */
    public static PricebookEntry createPricebook2(Boolean doInsert)
    {
        return createPricebook2(doInsert, createProduct2(true).Id);
    } 
    
    public static PricebookEntry createPricebook2(Boolean doInsert,Id prod2Id)
    {
    //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
         
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
         
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
         
         
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prod2Id,
            UnitPrice = 1020,
            IsActive = true
        );
        if(doInsert)
        {
            Insert pbe;
        }
        return pbe ;
        
    }
    /**
    * ***********************************************************
    * This method is test data for create OpportunityLineItem object
    * ***********************************************************
    */
    
    public static OpportunityLineItem createOpportunityLineItem(Boolean doInsert)
    {
        return createOpportunityLineItem(doInsert, createOpportunity(true).Id,createPricebook2(true).Id,createProduct2(true).Id);
    } 
    
    public static OpportunityLineItem createOpportunityLineItem(Boolean doInsert, Id opptId, Id pbeId,Id prod2Id)
    {
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opptId,
                                                                PricebookEntryId = pbeId,
                                                                UnitPrice = 10000,
                                                                Quantity = 10,
                                                                Product2Id=prod2Id);
        if(doInsert)
        {
            insert oppLineItem;
        }
        return oppLineItem;
    }
    
    /**
    * ***********************************************************
    * This method is test data for create GST__c object
    * ***********************************************************
    */
     
    public static GST__c createGST(Boolean doInsert)
    {
        GST__c gst = new GST__c(Name='Test GST 1');
        if(doInsert)
        {
            insert gst;
        }
        	return gst;

    }
}