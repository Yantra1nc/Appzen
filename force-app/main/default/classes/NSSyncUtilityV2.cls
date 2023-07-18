public class NSSyncUtilityV2 {
    
    //      VARIABLES : 
    public static boolean avoidRecurssion = false;
    public static string  parentObject ;
    private static List<SObject_Mapping__c> lstParentMappings ;         // List of parent mapping records
    private static List<SObject_Mapping__c> lstChildMappings ;          // List of child mapping records
    private static Map<Id,SObject_Mapping__c> recordMappingDetails = new Map<Id,SObject_Mapping__c>() ;         // Map of recordId and soject mapping record satisfying condition.
    private static Map<Id,sObject> parentRecords = new Map<Id,sObject>();               
    private static Map<String,Map<String,List<sObject>>> parentChildMap = new Map<String,Map<String,List<sObject>>>();   // Key: ParentId , Value : Map of child objectname and list of child records.
    private static Map<Id,List<SObject_Mapping__c>> parentChildMapping = new Map<Id,List<sObject_Mapping__c>>();
    
    private class SyncParent{
        sObject record;
        SObject_Mapping__c Mapping;
        boolean sendAccount;
        String parentObjectName;
        SObject_Mapping__c AccountMapping;
        sObject AccountRecord;
        Map<string,List<SyncChild>> childRecords;
        
        private syncParent(){  
            sendAccount = false;
        }
    }
    
    private class SyncChild{
        sObject record;
        SObject_Mapping__c Mapping;
    }
    @TestVisible
    public static void newSyncDataWithNetSuite(List<Sobject> lstSobject, String SobjectAPIName){
        avoidRecurssion = true;
        parentObject = SobjectAPIName;
        lstParentMappings =               [SELECT Id, Name,
                                           Relationship_Type__c,
                                           JSON_Sobject_Name__c,
                                           Parent_SObject_Map__c,
                                           
                                           Relationship_with_parent__c,
                                           Include_Billing_Address__c,
                                           Include_Shipping_Address__c,
                                           Include_Other_Address__c,
                                           Include_Mailing_Address__c,
                                           End_Point_URL__c,
                                           (SELECT Id, 
                                            Field_Type__c, 
                                            SObject_Mapping__c, 
                                            NetSuite_Field_API_Name__c, 
                                            SFDC_Field_API_Name__c,
                                            JSON_Sobject_Name__c,
                                            Type__c,
                                            IsActive__c
                                            FROM Field_Mappings__r WHERE IsActive__c = TRUE),
                                           (SELECT Id,
                                            Field_API_Name__c,
                                            Value__c 
                                            from Mapping_Conditions__r)
                                           FROM SObject_Mapping__c 
                                           WHERE Name =: SobjectAPIName  AND IsActive__c = TRUE]; 
        Set<Id> parentSobjectMappingIds = new Set<Id>();
        Set<Id> parentRecordIds = new Set<Id>();
        
        
        String relationshipType = '';
        Integer c = 0;
        for(sObject record : lstSobject){
            for(SObject_Mapping__c mapping : lstParentMappings){
                if(mapping.Mapping_Conditions__r.size() > 0){
                    for(Mapping_Condition__c condition : mapping.Mapping_Conditions__r ){
                        parentSobjectMappingIds.add(mapping.Id);
                        parentRecordIds.add(String.valueOf(record.get('Id')));
                        system.debug('condition '+condition);
                        system.debug('String.valueOf(record.get(condition.Field_API_Name__c) '+String.valueOf(record.get(condition.Field_API_Name__c)));
                        if(String.valueOf(record.get(condition.Field_API_Name__c)) != null){
                            if((String.valueOf(record.get(condition.Field_API_Name__c)).equalsIgnoreCase(condition.Value__c))){
                                system.debug('Adding Records');
                                recordMappingDetails.put(String.valueOf(record.get('Id')), mapping);
                                parentRecords.put(String.valueOf(record.get('Id')), record);
                                relationshipType = mapping.Relationship_Type__c;
                            }
                        }
                    }
                }else{
                                }
            }
        }
        List<SyncParent> serializeList = new List<SyncParent>();
        
        boolean isChild = false;
        isChild = getChildRecords(parentSobjectMappingIds, parentRecordIds);
        system.debug('isChild '+isChild);
        // Query accounts for opportunity records
        Map<Id,Account> oppAccMap = new Map<Id,Account>();
        List<SObject_Mapping__c> accountMappingRecord = new List<SObject_Mapping__c>();
        
        if(SobjectAPIName == 'Opportunity' ){
            List<Opportunity> opportunityRecords = [Select Id,AccountId from Opportunity where Id IN:parentRecords.keySet()];
            Set<Id> AccountIds = new Set<Id>();
            for(Opportunity o :opportunityRecords){
                AccountIds.add(o.AccountId);
            }
            List<Account> accountlist = new List<Account>();
            accountMappingRecord =          [SELECT Id, Name,
                                             Relationship_Type__c,
                                             JSON_Sobject_Name__c,
                                             Parent_SObject_Map__c,
                                             
                                             Relationship_with_parent__c,
                                             Include_Billing_Address__c,
                                             Include_Shipping_Address__c,
                                             Include_Other_Address__c,
                                             Include_Mailing_Address__c,
                                             
                                             (SELECT Id, 
                                              Field_Type__c, 
                                              SObject_Mapping__c, 
                                              NetSuite_Field_API_Name__c, 
                                              SFDC_Field_API_Name__c,
                                              JSON_Sobject_Name__c,
                                              Type__c,
                                              IsActive__c
                                              FROM Field_Mappings__r WHERE IsActive__c = TRUE)
                                             FROM SObject_Mapping__c 
                                             WHERE Name = 'Account'  AND IsActive__c = TRUE limit 1]; 
            
            String query = 'SELECT ';
            for(Field_Mapping__c field : accountMappingRecord.get(0).Field_Mappings__r){
                query += field.SFDC_Field_API_Name__c +',';
            }
            query += 'BillingStreet,BillingCity,BillingState,BillingCountry,Billingpostalcode,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,Shippingpostalcode';
            query = query.removeEnd(',');
            query += ' FROM ACCOUNT  Where ID IN : AccountIds' ;
            system.debug('query '+query);
            accountlist= database.query(query);
            Map<Id,Account> accountRecords = new Map<Id,Account>(accountlist);
            system.debug('accountRecords '+accountRecords);
            
            for(Opportunity o :opportunityRecords){
                oppAccMap.put(o.Id,accountRecords.get(o.AccountId));
            }
        } 
        if(!isChild){
            for(sObject PR : parentRecords.values()){
                system.debug('!!! set Billing address ');
                
                SyncParent P = new SyncParent();
                Map<String,List<SyncChild>> tempMap = new Map<String,List<SyncChild>>();
                P.record = PR;
                P.Mapping = recordMappingDetails.get(String.valueOf(PR.get('Id')));
                system.debug('^^^^ Netsuite_Id__c '+String.valueOf(PR.get('Netsuite_Id__c')));
                system.debug(' ^^^ recordMappingDetails. '+ recordMappingDetails.get(String.valueOf(PR.get('Id'))).Name);
                if(SobjectAPIName == 'Opportunity' && String.valueOf(PR.get('Netsuite_Id__c')) == null && oppAccMap.get(String.valueOf(PR.get('Id'))) != null ){
                    p.sendAccount = true;
                    P.AccountRecord = (sObject) oppAccMap.get(String.valueOf(PR.get('Id')));
                    p.AccountMapping = accountMappingRecord.get(0);
                }else{
                    p.sendAccount = false;
                }
                serializeList.add(P);
                
            }
        }else{
            system.debug('parentChildMap '+parentChildMap);
            for(sObject PR : parentRecords.values()){
                
                SyncParent P = new SyncParent();
                Map<String,List<SyncChild>> tempMap = new Map<String,List<SyncChild>>();
                P.record = PR;
                P.Mapping = recordMappingDetails.get(String.valueOf(PR.get('Id')));
                
                system.debug('^^^^ Netsuite_Id__c '+String.valueOf(PR.get('Netsuite_Id__c')));
                system.debug(' ^^^ recordMappingDetails. '+ recordMappingDetails.get(String.valueOf(PR.get('Id'))).Name);
                system.debug('^^^^ oppAccMap.get(id) '+oppAccMap);
               
                if(SobjectAPIName == 'Opportunity' && 
                   oppAccMap.get(String.valueOf(PR.get('Id'))) != null ){
                       p.sendAccount = true;
                       P.AccountRecord = (sObject) oppAccMap.get(String.valueOf(PR.get('Id')));
                       system.debug('^^^^ P.AccountRecord '+P.AccountRecord);
                       p.AccountMapping = accountMappingRecord.get(0);
                       system.debug('^^^^ p.AccountMapping '+p.AccountMapping);
                   }else{
                       p.sendAccount = false;
                   }
                
                system.debug('%% P.Mapping'+recordMappingDetails.get(String.valueOf(PR.get('Id'))));
                if(parentChildMap.containsKey(String.valueOf(PR.get('Id')))){
                    for(String childObjectName : parentChildMap.get(String.valueOf(PR.get('Id'))).keyset()){
                        SObject_Mapping__c childMapping ;
                        system.debug('childObjectName '+childObjectName);
                        if(parentChildMapping.containsKey(recordMappingDetails.get(String.valueOf(PR.get('Id'))).Id)){
                            for(SObject_Mapping__c cm :parentChildMapping.get(recordMappingDetails.get(String.valueOf(PR.get('Id'))).Id)){
                                system.debug('%%cm '+cm);
                                if(cm.Name == childObjectName){
                                    system.debug('===== '+cm);
                                    childMapping = cm;
                                    break;
                                }   
                            }
                            List<SyncChild> lstCh = new List<SyncChild>();
                            for(sObject childRecord : parentChildMap.get(String.valueOf(PR.get('Id'))).get(childObjectName)){
                                SyncChild Ch = new SyncChild();
                                Ch.record = childRecord;
                                Ch.Mapping = childMapping;
                                lstCh.add(Ch);
                                system.debug('%%Child '+Ch);
                            }
                            tempMap.put(childObjectName,lstCh);
                        }
                    }
                    P.childRecords = tempMap;
                }else{
                    
                    // no childs
                }
                serializeList.add(P);
            }
        }
        system.debug('serializeList '+serializeList);
        
        
        
        if(serializeList.size() > 0){
            system.debug('Calling newprepareJSON');
            String JSONBody = createJSON(serializeList,parentChildMapping);
            system.debug('$$$$$$$ JSONBody'+JSONBody);
            if(String.isBlank(JSONBody) || String.isEmpty(JSONBody)) return;
            makeCallout(JSONBody, SobjectAPIName);
        }
        
    }
    
    @TestVisible
    private static boolean getChildRecords(Set<Id> parentSobjectMappingIds,Set<Id> parentRecordIds){
        lstChildMappings =               [SELECT Id, Name,
                                          Relationship_Type__c,
                                          JSON_Sobject_Name__c,
                                          Parent_SObject_Map__c,
                                          
                                          Relationship_with_parent__c,
                                          (SELECT Id, 
                                           Field_Type__c, 
                                           SObject_Mapping__c, 
                                           NetSuite_Field_API_Name__c, 
                                           SFDC_Field_API_Name__c,
                                           JSON_Sobject_Name__c,
                                           Type__c,
                                           IsActive__c
                                           FROM Field_Mappings__r WHERE IsActive__c = TRUE),
                                          (SELECT Id,
                                           Field_API_Name__c,
                                           Value__c 
                                           from Mapping_Conditions__r)
                                          FROM SObject_Mapping__c 
                                          WHERE Parent_SObject_Map__c IN : parentSobjectMappingIds  AND IsActive__c = TRUE];         
        
        if(lstChildMappings.size() > 0){
            system.debug('lstChildMappings '+lstChildMappings);
            Map<String,Set<String>> childFields = new Map<String,Set<String>>();
            Map<String,String> relationshipNameMap = new Map<String,String>();
            for(SObject_Mapping__c childMapping : lstChildMappings){
                system.debug('Iterating child mappings '+childMapping);
                system.debug('childMapping.Parent_SObject_Map__c '+childMapping.Parent_SObject_Map__c);
                relationshipNameMap.put(childMapping.Name,childMapping.Relationship_with_parent__c);
                List<SObject_Mapping__c> tempList = new List<SObject_Mapping__c>();
                if(parentChildMapping.keyset().contains(childMapping.Parent_SObject_Map__c)){
                    tempList = parentChildMapping.get(childMapping.Parent_SObject_Map__c);
                }
                tempList.add(childMapping);
                parentChildMapping.put(childMapping.Parent_SObject_Map__c,tempList);
                SObjectType objectType = Schema.getGlobalDescribe().get(childMapping.Name);
                Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
                childFields.put(childMapping.Name,mfields.keyset());
            }
            system.debug('%%relationshipNameMap '+relationshipNameMap);
            system.debug(' %%parentChildMapping '+parentChildMapping);
            
           Map<String,List<sObject>> childRecords = new Map<String,List<sObject>>();
            
            if(childFields.keySet().size() > 0){
                system.debug('%%vchildFields '+childFields.keyset());
                for(String childObject : childFields.keyset()){
                    system.debug('^^^^^^^^ childObject '+childObject);
                    List<sObject> childList = new List<sObject>();
                    String query = 'SELECT ';
                    for(String field : childFields.get(childObject)){
                        system.debug('^^^^^^^^^^^ field '+field);
                        query += field +',';
                    }
                    if(childObject == 'OpportunityContactRole'){
                        system.debug('^^^^^^^^ childfield ');
                        query += 'contact.Salutation,contact.Netsuite_Id__c,contact.LeadSource,contact.FirstName,contact.LastName,contact.Fax,contact.AssistantPhone,contact.Department,contact.email,contact.HomePhone,contact.Title,';
                        query += 'contact.MailingStreet,contact.MailingCity,contact.MailingState,contact.MailingCountry,contact.MailingPostalCode,contact.MobilePhone,contact.OtherPhone,contact.Phone,contact.AccountId,';
                        query += 'contact.OtherStreet,contact.OtherCity,contact.OtherState,contact.OtherCountry,contact.OtherPostalCode';
                    }
                    query = query.removeEnd(',');
                    if(childObject == 'OpportunityContactRole'){
                        Set<String> roles = new Set<String>{'Champion','Billing/Accounts Payable'};
                        query += ' FROM '+ childObject +' Where '+ relationshipNameMap.get(childObject) +' IN : parentRecordIds AND Role IN:roles';
                        system.debug(' Query generated ->'+query);
                    } 
                    else {
                        query += ' FROM '+ childObject +' Where '+ relationshipNameMap.get(childObject) +' IN : parentRecordIds' ;
                    }   
                    
                    system.debug('^^^^^^^^^^^ query '+query);
                    childList= database.query(query);
                    childRecords.put(childObject, childList);
                }
            }
            system.debug(' %%childRecords '+childRecords); 
            for(String childObject :  childRecords.keyset()){
                system.debug(' %% childObject '+childObject);
                Map<String,List<sObject>> a = new Map<String,List<sObject>>();
                for(sObject record :  childRecords.get(childObject)){
                    system.debug(' %%record '+record);
                    String parentRecordId = String.valueOf(record.get(relationshipNameMap.get(childObject)));
                    if(parentChildMap.keySet().contains(parentRecordId)){
                        system.debug('%% parentChildMap.get(parentRecordId).keyset().contains(childObject) '+parentChildMap.get(parentRecordId).keyset().contains(childObject));
                        if(parentChildMap.get(parentRecordId).keyset().contains(childObject)){
                            parentChildMap.get(parentRecordId).get(childObject).add(record);
                        }else{
                            Map<String,List<sObject>> tempMap = parentChildMap.get(parentRecordId);
                            List<sObject> tempList2 = new List<sObject>();
                            tempList2.add(record);
                            tempMap.put(childObject,tempList2);
                            parentChildMap.get(parentRecordId).put(childObject,tempList2);
                        }
                    }else{
                        system.debug('%% New ');
                        List<sObject> tempList = new List<sObject>();
                        tempList.add(record);
                        a.put(childObject,tempList);
                        parentChildMap.put(parentRecordId, a);
                    }
                }
            }
            return true;
        }else{
            //parentChildMap
            return false;
        }
    }
    
    @TestVisible
    Private static String createJSON(List<SyncParent> serializeList, Map<Id,List<SObject_Mapping__c>> parentChildMapping){
        String jsonString = '';//{   
        String parentNode = '';
        boolean flag = false;
        String jsonContent = '';
        for(SyncParent parent : serializeList){
            jsonContent += '{';
            if(!flag){
                parentNode += '"' + recordMappingDetails.get(String.valueOf(parent.record.get('Id'))).JSON_Sobject_Name__c +'" : [';
                flag = true;
            }
            String addressString = '';
            system.debug('$$ parent.record '+parent.record);
            system.debug('$$ parent.mapping '+parent.mapping);
            system.debug('recordMappingDetails '+recordMappingDetails);
            system.debug('String.valueOf(parent.record.get("Id")) '+String.valueOf(parent.record.get('Id')));
            system.debug('recordMappingDetails.get(String.valueOf(parent.record.get(Id))) '+recordMappingDetails.get(String.valueOf(parent.record.get('Id'))));
            String parentPart = newSerializeSobject1(parent.record, parent.mapping.Field_Mappings__r, recordMappingDetails.get(String.valueOf(parent.record.get('Id'))).JSON_Sobject_Name__c);
            String addressStr = '';
            if(parent.mapping.include_billing_address__c && parentObject == 'Account' ){
                system.debug('Serializing billing address');
                addressStr += '{' + serializeAddress(parent.record,'Billing') + '},';
            }
            if(parent.mapping.include_shipping_address__c && parentObject == 'Account') {
                addressStr += '{' +serializeAddress(parent.record,'Shipping') +'},';
            }
            if(parent.mapping.include_other_address__c && parentObject == 'Contact' ){
                system.debug('Serializing billing address');
                addressStr += '{' + serializeAddress(parent.record,'Other') + '},';
            }
            if(parent.mapping.include_mailing_address__c && parentObject == 'Contact') {
                addressStr += '{' +serializeAddress(parent.record,'Mailing') +'},';
            }
            
            addressStr = addressStr.removeEnd(',');
            if(addressStr != '')
                parentPart += ',"addressbook" : [' + addressStr +']';
            
            String childStr = '';  
            String accStr = '';
            SObject_Mapping__c childMapping = new SObject_Mapping__c();
            if(parent.childRecords != null){
                for(String childObjectName : parent.childRecords.keySet() ){
                    for(SObject_Mapping__c cm :parentChildMapping.get(recordMappingDetails.get(String.valueOf(parent.record.get('Id'))).Id)){
                        system.debug('%%cm '+cm);
                        if(cm.Name == childObjectName){
                            childMapping = cm;
                            break;
                        }   
                    }
                    
                    childStr += '"' + childMapping.JSON_Sobject_Name__c +'" : [';
                    for(SyncChild child : parent.childRecords.get(childObjectName)){
                        system.debug(' $$child '+child);
                        system.debug('$$ value  '+newSerializeSobject1(child.record, childMapping.Field_Mappings__r, childMapping.JSON_Sobject_Name__c));
                        childStr += '{';
                        childStr += newSerializeSobject1(child.record, childMapping.Field_Mappings__r, childMapping.JSON_Sobject_Name__c);
                        childStr += '},';
                    }
                    childStr = childStr.removeEnd(',');
                    childStr += '],';
                }
                childStr = childStr.removeEnd(',');
            }
            if(parent.sendAccount){
                accStr += '"' + parent.AccountMapping.JSON_Sobject_Name__c +'" : {';
                accStr +=  newSerializeSobject1(parent.AccountRecord, parent.AccountMapping.Field_Mappings__r, parent.AccountMapping.JSON_Sobject_Name__c);
                
                String addressStrChild = '';
                system.debug('!!! parent.AccountMapping.include_billing_address__c '+parent.AccountMapping.include_billing_address__c);
                if(parent.AccountMapping.include_billing_address__c  ){
                    system.debug('Serializing billing address');
                    addressStrChild += '{' + serializeAddress(parent.AccountRecord,'Billing') + '},';
                }
                if(parent.AccountMapping.include_billing_address__c ) {
                    addressStrChild += '{' +serializeAddress(parent.AccountRecord,'Shipping') +'},';
                }
                system.debug('!!! addressStrChild '+addressStrChild);
                addressStrChild = addressStrChild.removeEnd(',');
                if(addressStrChild != '')
                    accStr += ',"addressbook" : [' + addressStrChild +']';
                
                accStr += '}';
                system.debug('^^^^ accStr'+accStr);
            }
            if(parentPart != null){
                jsonContent +=  parentPart;
            }
            system.debug('$$childStr '+childStr);
            if(accStr != ''){
                jsonContent += ',';
                jsonContent += accStr;
            }
            
            if(childStr != ''){
                system.debug('$$Child Present');
                jsonContent += ',';
                jsonContent += childStr; 
            }
            jsonContent += '},';
        }
        jsonContent = jsonContent.removeEnd(',');
        String operation = '';
        if(Trigger.isUpdate){
            operation = 'Update';
        }
        if(Trigger.isInsert){
            operation = 'Insert';
        }
        
        if(Trigger.isDelete){
            operation = 'Delete';
        }
        
        jsonString += '{'+ '"Operation" : "'+operation+'", '+parentNode + jsonContent +']' ;
        jsonString += '}';
        system.debug('$$FINAL '+jsonString);
        return jsonString;
    }
    
    @TestVisible
    private static String serializeAddress(sObject record, String addressType){
        String addStr = '';
        if(addressType == 'Billing'){
            if(record.get('BillingStreet') != null){
                addStr += '"Street" :  "' + String.valueOf(record.get('BillingStreet')) +'" ,' ;
            }
            system.debug('!! city ' +record.get('BillingCity'));
            system.debug('!! City 2'+String.valueOf(record.get('BillingCity')));
            if(record.get('BillingCity') != null){
                addStr += '"City" :  "' + String.valueOf(record.get('BillingCity')) +'",' ;
            }
            system.debug('!! addStr '+addStr);
            if(record.get('BillingState') != null){
                addStr += '"State" :  "' + String.valueOf(record.get('BillingState')) +'",' ;
            }
            
            if(record.get('Billingpostalcode') != null){
                addStr += '"ZIP" :  "' + String.valueOf(record.get('Billingpostalcode')) +'",' ;
            }
            if(record.get('BillingCountry') != null){
                addStr += '"Country" :  "' + String.valueOf(record.get('BillingCountry')) +'",' ;
            }
            addStr += '"Type" :  "' + addressType +'"' ;
            system.debug('!!! Address '+addStr );
        }
        
        if(addressType == 'Shipping'){
            if(record.get('ShippingStreet') != null){
                addStr += '"Street" :  "' + String.valueOf(record.get('ShippingStreet')) +'" ,' ;
            }
            system.debug('!! city ' +record.get('ShippingCity'));
            system.debug('!! City 2'+String.valueOf(record.get('ShippingCity')));
            if(record.get('ShippingCity') != null){
                addStr += '"City" :  "' + String.valueOf(record.get('ShippingCity')) +'",' ;
            }
            system.debug('!! addStr '+addStr);
            if(record.get('ShippingState') != null){
                addStr += '"State" :  "' + String.valueOf(record.get('ShippingState')) +'",' ;
            }
            
            if(record.get('Shippingpostalcode') != null){
                addStr += '"ZIP" :  "' + String.valueOf(record.get('Shippingpostalcode')) +'",' ;
            }
            if(record.get('ShippingCountry') != null){
                addStr += '"Country" :  "' + String.valueOf(record.get('ShippingCountry')) +'",' ;
            }
            addStr += '"Type" :  "' + addressType +'"' ;
            system.debug('!!! Address '+addStr );
        }
        
        if(addressType == 'Other'){
            if(record.get('OtherStreet') != null){
                addStr += '"Street" :  "' + String.valueOf(record.get('OtherStreet')) +'" ,' ;
            }
            system.debug('!! city ' +record.get('OtherCity'));
            system.debug('!! City 2'+String.valueOf(record.get('OtherCity')));
            if(record.get('OtherCity') != null){
                addStr += '"City" :  "' + String.valueOf(record.get('OtherCity')) +'",' ;
            }
            system.debug('!! addStr '+addStr);
            if(record.get('OtherState') != null){
                addStr += '"State" :  "' + String.valueOf(record.get('OtherState')) +'",' ;
            }
            
            if(record.get('Otherpostalcode') != null){
                addStr += '"ZIP" :  "' + String.valueOf(record.get('Otherpostalcode')) +'",' ;
            }
            if(record.get('OtherCountry') != null){
                addStr += '"Country" :  "' + String.valueOf(record.get('OtherCountry')) +'",' ;
            }
            addStr += '"Type" :  "' + addressType +'"' ;
            system.debug('!!! Address '+addStr );
        }
        if(addressType == 'Mailing'){
            if(record.get('MailingStreet') != null){
                addStr += '"Street" :  "' + String.valueOf(record.get('MailingStreet')) +'" ,' ;
            }
            system.debug('!! city ' +record.get('MailingCity'));
            system.debug('!! City 2'+String.valueOf(record.get('MailingCity')));
            if(record.get('MailingCity') != null){
                addStr += '"City" :  "' + String.valueOf(record.get('MailingCity')) +'",' ;
            }
            system.debug('!! addStr '+addStr);
            if(record.get('MailingState') != null){
                addStr += '"State" :  "' + String.valueOf(record.get('MailingState')) +'",' ;
            }
            
            if(record.get('Mailingpostalcode') != null){
                addStr += '"ZIP" :  "' + String.valueOf(record.get('Mailingpostalcode')) +'",' ;
            }
            if(record.get('MailingCountry') != null){
                addStr += '"Country" :  "' + String.valueOf(record.get('MailingCountry')) +'",' ;
            }
            addStr += '"Type" :  "' + addressType +'"' ;
            system.debug('!!! Address '+addStr );
        }
        return addStr;
    }
    
    @TestVisible
    private static String newSerializeSobject1(Sobject sobj , List<Field_Mapping__c> lstFieldMapping,String JSONobjectName){
        String singleJSONrec ='';
        String strParentFieldJSON =''; 
        String strChildFieldJSON ='';
        for(Field_Mapping__c objFM : lstFieldMapping){
            strParentFieldJSON += String.isEmpty(strParentFieldJSON) ? serializeField(sobj, objFM.SFDC_Field_API_Name__c, objFM.NetSuite_Field_API_Name__c, objFM.Field_Type__c):
            ',' + serializeField(sobj, objFM.SFDC_Field_API_Name__c, objFM.NetSuite_Field_API_Name__c, objFM.Field_Type__c);
        }
        singleJSONrec += strParentFieldJSON;
        system.debug('====== JSON '+ singleJSONrec);
        return singleJSONrec;
    }
    
    @future (callout = true)
    @TestVisible
    private static void makeCallout(String JSONBody, String sObjectName){
        List <SObject_Mapping__c> myurl = [SELECT End_Point_URL__c FROM SObject_Mapping__c where name =:sObjectName limit 1];
        String myendpointurl = string.valueOf(myurl[0].End_Point_URL__c);
        String rawjson;
        String[] strArray  = myendpointurl.split('&');
        String script = strArray[0];
        script = script.replace('?','');
        
        Netsuite_OAuth__c OAuthDetails = [SELECT Customer_Key__c,Customer_Secret__c,Realm__c,
                                          Signature_Method__c,Token__c,Token_Secret__c,End_Point_URL__c FROM Netsuite_OAuth__c limit 1];
        system.debug('#####OAuthDetails '+OAuthDetails);
        // pass end point url.
        system.debug('**********');
        system.debug(sObjectName);
        system.debug(myendpointurl);
        String endpointURL = OAuthDetails.End_Point_URL__c + myendpointurl ; 
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String version = '1.0';
        String timestamp = String.valueOf(DateTime.now().getTime()/1000); //seconds since unix epoch
        String nonce = String.valueOf(Crypto.getRandomLong()); //random number
        
        String OAuthHeader = 'OAuth ';
        OAuthHeader += 'realm="'+OAuthDetails.Realm__c+'",';
        OAuthHeader += 'oauth_consumer_key="'+OAuthDetails.Customer_Key__c+'",';
        OAuthHeader += 'oauth_token="'+OAuthDetails.Token__c+'",';
        OAuthHeader += 'oauth_signature_method="'+OAuthDetails.Signature_Method__c+'",';
        OAuthHeader += 'oauth_timestamp="'+timestamp+'",';
        OAuthHeader += 'oauth_nonce="'+nonce+'",';
        OAuthHeader += 'oauth_version="1.0",';
        String raw;   
        String encodedString = EncodingUtil.URLENCODE(OAuthDetails.End_Point_URL__c,'UTF-8');
        String signUrl = 'deploy=1&oauth_consumer_key='+OAuthDetails.Customer_Key__c+'&oauth_nonce='+nonce+'&oauth_signature_method='+OAuthDetails.Signature_Method__c+'&oauth_timestamp='+timestamp+'&oauth_token='+OAuthDetails.Token__c+'&oauth_version=1.0&'+ script;
        String signature1 = 'POST&'+encodedString+'&'+EncodingUtil.URLENCODE(signUrl,'UTF-8');
        String key = OAuthDetails.Customer_Secret__c +'&'+ OAuthDetails.Token_Secret__c;
        Blob hmacData = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(signature1), Blob.valueOf(key));
        String signatureKey = EncodingUtil.base64Encode(hmacData);
        String finalGeneratedSignature = EncodingUtil.URLENCODE(signatureKey,'UTF-8');
        OAuthHeader += 'oauth_signature="'+finalGeneratedSignature+'"';
        system.debug('signUrl '+signUrl);
        req.setHeader('Authorization',OAuthHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody(JSONBody);
        req.setEndpoint(endPointUrl);
        
        try {
            HttpResponse res = http.send(req);
            System.debug('======res.getBody()===='+res.getBody());
            rawjson = JSON.serializePretty(JSONBody);
            JSON_Log__c json = New JSON_Log__c();
            json.JSON_Payload__c = JSONBody.abbreviate(5999); //showing only 5999 characters as the field limit
            json.Name = 'Payload at '+Datetime.now();
            insert json;
            
            System.debug('rawjson = '+rawjson);
           
            if(res.getStatusCode() == 200){
            }else{
                system.debug('####res '+res);
            }
        } catch(System.CalloutException e) {
            System.debug('========e======='+e);
        }
    }
    
    // Method to send serialized response of one field.
    @TestVisible
    private static String serializeField(Sobject objSobject, String SFDCFieldAPIName, String NetSuiteFieldAPIName, String fieldType){
        System.debug(' ======SFDCFieldAPIName======='+SFDCFieldAPIName);
        system.debug(' ^^^^ SFDCFieldAPIName.contains'+ SFDCFieldAPIName.contains('.'));
        system.debug(' ^^^^ SFDCFieldAPIName  '+ SFDCFieldAPIName);
        
        if(SFDCFieldAPIName != null && SFDCFieldAPIName.contains('.')){
            List<String> lstVar = new List<String>();
            lstVar = SFDCFieldAPIName.split('\\.');
            system.debug('^^^^^^ lstVar '+lstVar);
            system.debug('^^^^^^objSobject '+objSobject);
            system.debug('^^^^^^^^^^^^SFDCFieldAPIName '+SFDCFieldAPIName);
            
            string test = '"' + NetSuiteFieldAPIName+'" : "' + String.valueOf(objSobject.getSObject(lstVar[0]).get(lstVar[1]))+'"';
            system.debug('^^^^^^^^^ test '+test);
            return '"' + NetSuiteFieldAPIName+'" : "' + String.valueOf(objSobject.getSObject(lstVar[0]).get(lstVar[1]))+'"'; 
        }
        
        if(objSobject.get(SFDCFieldAPIName) == null) return '"' + NetSuiteFieldAPIName+'" : ""';
        if(fieldType == 'Checkbox'){
            return '"' + NetSuiteFieldAPIName+'" : "' + Boolean.valueOf(objSobject.get(SFDCFieldAPIName))+'"';
        } else if(fieldType == 'Date'){
            return '"' + NetSuiteFieldAPIName+'" : "' + String.valueOf(objSobject.get(SFDCFieldAPIName)).removeEnd(' 00:00:00')+'"';
        } else if(fieldType == 'Date/Time'){
            return '"' + NetSuiteFieldAPIName + '" : "' + DateTime.valueOf(objSobject.get(SFDCFieldAPIName))+'"';
        } else if(fieldType == 'Number' || fieldType == 'Percent' || fieldType == 'Currency'){
            return '"' + NetSuiteFieldAPIName + '" : "' + Double.valueOf(objSobject.get(SFDCFieldAPIName))+'"';
        } else if(fieldType == 'Phone' || fieldType == 'Picklist' || fieldType == 'Text' || fieldType == 'Text Area' || fieldType == 'URL' || fieldType == 'Email'){
            return '"' + NetSuiteFieldAPIName + '" : ' + '"' + String.valueOf(objSobject.get(SFDCFieldAPIName)) + '"';
        } else {
            return '"' + NetSuiteFieldAPIName + '" : ' + '"' + String.valueOf(objSobject.get(SFDCFieldAPIName)) + '"';
        }
    }
}