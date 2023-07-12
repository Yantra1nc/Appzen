public class UnicommerceCustomerMasterExportStatus implements Queueable,Database.AllowsCallouts{
    
    public String jobCode;
    public String token;
    
    public UnicommerceCustomerMasterExportStatus(String jobCode,String token){
        this.jobCode = jobCode;
        this.token = token;
        
    }
    
    public void execute(QueueableContext qc){
        String filePath = createFilePathCustomerMaster(jobCode,token);
        System.debug('Filepath '+filePath);
        calloutForCSV(filePath);
    }
    
    public static String createFilePathCustomerMaster(String jobCode,String token){
        
        
        UnicommerceExportJobStatus__c custSettings = UnicommerceExportJobStatus__c.getValues('JobStatusUrl');
        String apiEndpoint = custSettings.ExportJobStatus__c;
        Map<String,Object> mapResponse = new Map<String,Object>();
        System.debug('Token '+token);
        System.debug('JOB '+jobCode);
        System.debug('ENDPOINT '+apiEndpoint);
        try{
            if(token != null && jobCode != null){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+token);
                req.setMethod('POST');
                req.setEndpoint(apiEndpoint);
                req.setTimeout(120000);
                String reqBody = '{'+
                    '"jobCode": "'+jobCode+'"'+
                    '}';
                req.setBody(reqBody);
                HttpResponse response = http.send(req);
                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                System.debug('Print Response '+ mapResponse);
                if(response.getStatusCode() == 200){
                    if(mapResponse.get('successful') == true && mapResponse.get('status') == 'COMPLETE'){
                        System.debug('FilePath '+mapResponse.get('filePath'));                       
                    }
                }
            }
            System.debug('FilePath '+(String)mapResponse.get('filePath'));
            
            
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            System.debug('Exception '+ex.getStackTraceString());
            System.debug('Exception '+ex.getLineNumber());
        }
        return (String)mapResponse.get('filePath');
    }
    
    public static void calloutForCSV(String fileUrl){
        Map<String,Account> mapAcc = new Map<String,Account>();
        
        
        String result;  
        List<Account> lstToUpdate = new List<Account>();
        List<Account> lstToInsert = new List<Account>(); 
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/csv');      
        req.setMethod('GET');
        req.setEndpoint(fileUrl);
        try{
            HttpResponse res = http.send(req);                       
            Blob csvBlob = res.getBodyAsBlob(); 
            String csvString = csvBlob.toString();
            //CSV Reader instance
            SSSCsvReader csvObj = new SSSCsvReader(csvString);
            
            String[] csvLines = csvString.split('\n');
            
            //code block to get picklistAPI
            Map<String,String>codemap = new Map<String,String>();
            Set<String>codeSet = new Set<String>();
            Schema.DescribeFieldResult fieldResult = Account.Distrbution_Channel__c.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : values){
                codeSet.add(pickListVal.getLabel());
            }     
            
            Set<String>customerCodes = new Set<String>();
            Map<String,Account>parentToUpsert = new Map<String,Account>();
            Map<String,Account>parentAccounts = new Map<String,Account>();
            
            Set<String>SPCodeSet = new Set<String>();
            Set<String>SHCodeSet = new Set<String>();
            
            //get customer Ids from file
            for(String str:csvLines){
                String[] csvRecordData = str.split(','); 
                
                //data wrapper to get data
                ChannelWraper obj = getTypeAndCode(csvRecordData[0],codeSet);
                String Customer_Type = '';
                String distCode = '';
                if(obj != null){
                    Customer_Type = obj.Customer_Type;
                    distCode = obj.distCode;
                }
                if(csvRecordData[0] != null){
                    customerCodes.add(csvRecordData[0]);
                }
                if(csvRecordData[12] != null){
                    SHCodeSet.add(csvRecordData[12]);
                }
                if(csvRecordData[13] != null){
                    SPCodeSet.add(csvRecordData[13]);
                }
                
            }
            
            
            //get Parent accounts
            for(Account acc:[Select Id,Name,Parent.Customer_Code_SOP__c,Service_Tax_Number__c,Customer_Code_SOP__c,Email_Address__c,Distrbution_Channel__c,Customer_Type__c,Customer_Code__c,(Select Id,Email,FirstName,LastName from Contacts) from Account where Customer_Code__c in:customerCodes ]){
                if(acc.Customer_Code__c != null){
                    parentAccounts.put(acc.Customer_Code__c, acc);
                }
            } 
            
            System.debug('parentAccounts '+parentAccounts);
            List<Contact>contactToInseret = new list<Contact>();
            
            //get existing Accounts    
            for(Account acc:[Select Id,Name,Parent.Customer_Code_SOP__c,Service_Tax_Number__c,Customer_Code_SOP__c,Email_Address__c,Distrbution_Channel__c,Customer_Type__c,Customer_Code__c,(Select Id,Email,FirstName,LastName from Contacts) from Account where Customer_Code__c in:customerCodes ]){
                if(acc.Customer_Code__c != null){
                    mapAcc.put(acc.Customer_Code__c, acc);
                }
            }
            
            //Parent account insert here
            for(String str:csvLines){
                wrappercls wrapObj = new wrappercls();
                String[] csvRecordData = csvObj.readLine();
                if(csvRecordData != null && csvRecordData.size() > 0){
                    ChannelWraper obj = getTypeAndCode(csvRecordData[0],codeSet);
                    String Customer_Type = '';
                    String distCode = '';
                    if(obj != null){
                        Customer_Type = obj.Customer_Type;
                        distCode = obj.distCode;
                    }
                    
                    if(csvRecordData[12] != null && String.isNotBlank(csvRecordData[13]) && csvRecordData[12] != null && String.isNotBlank(csvRecordData[13]) && csvRecordData[12].remove('_SH').equalsIgnoreCase(csvRecordData[13].remove('_SP')) ){
                        Account newAccount = new Account();
                        
                        if(parentAccounts.containsKey(csvRecordData[0])){
                            newAccount = parentAccounts.get(csvRecordData[0]);
                        }else{
                            newAccount.ParentId = null;
                        }
                        
                        if(newAccount.ParentId != null && newAccount.Customer_Code_SOP__c != newAccount.Parent.Customer_Code_SOP__c){
                            newAccount.ParentId = null;
                        }
                        
                        newAccount.Customer_Code__c = csvRecordData[0];
                        newAccount.isParent__c = true;
                        newAccount.Name = csvRecordData[1];
                        newAccount.Service_Tax_Number__c = csvRecordData[12];
                        newAccount.Customer_Code_SOP__c = csvRecordData[13];
                        newAccount.Phone = csvRecordData[4];
                        newAccount.BillingStreet = csvRecordData[5]+' '+csvRecordData[6];
                        newAccount.BillingState = csvRecordData[8];
                        newAccount.BillingCity = csvRecordData[7];
                        newAccount.BillingCountry = csvRecordData[9];
                        
                        if(String.isNotBlank(distCode)){
                            newAccount.Customer_Type__c = Customer_Type;
                            newAccount.Distrbution_Channel__c = distCode;
                        }
                        
                        newAccount.ShippingStreet = csvRecordData[14]+' '+csvRecordData[15];
                        newAccount.ShippingCity = csvRecordData[16].length() > 20 ? csvRecordData[16].substring(0,19) : csvRecordData[16] ;
                        newAccount.ShippingCountry = csvRecordData[18].length() > 20 ? csvRecordData[18].substring(0,19) : csvRecordData[18];
                        newAccount.ShippingState = csvRecordData[17].length() > 20 ? csvRecordData[17].substring(0,19) : csvRecordData[17];
                        newAccount.ShippingPostalCode = csvRecordData[19].length() > 20 ? csvRecordData[19].substring(0,19) : csvRecordData[19];
                        if(newAccount.Service_Tax_Number__c != null && newAccount.Customer_Code_SOP__c != null &&
                           newAccount.Service_Tax_Number__c.removeEnd('_SH').equalsIgnoreCase(newAccount.Customer_Code_SOP__c.removeEnd('_SP')) ){
                               newAccount.ParentId = null;
                           }
                        parentToUpsert.put(newAccount.Customer_Code__c,newAccount);
                                    }
                }
            }
            System.debug('parentToUpsert '+parentToUpsert.keyset());
            System.debug('parentToUpsert '+JSON.serialize(parentToUpsert));
            System.debug('parentToUpsert value '+parentToUpsert.containsKey('610441_63'));
            if(!parentToUpsert.isEMpty()){
                Upsert parentToUpsert.values();
            } 
            
            
            SSSCsvReader csvObj2 = new SSSCsvReader(csvString);
            Map<String,Address__c>addressMapToUpsert = new Map<String,Address__c>();
            Id recordtypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('Shipping_Address').getRecordTypeId();
            Map<String,Address__c>addressMapExisting = new Map<String,Address__c>();
            
            System.debug('SHCodeSet '+SHCodeSet);
            
            for(Address__c addrObj : [Select id,Customer_Code_SHP__c,Account__c,Shipping_City__c,Shipping_Country__c,Shipping_State_Province__c,Shipping_Street__c,Shipping_Zip_Postal_Code__c from Address__c where  Customer_Code_SHP__c != null]){
                addressMapExisting.put(addrObj.Customer_Code_SHP__c,addrObj);
            }
            
            System.debug('addressMapExisting '+JSON.serialize(addressMapExisting));
            
            Map<String,Account>childAccInsert = new Map<String,Account>();
            Map<String,Account>childAccUpdate = new Map<String,Account>();
            
            //child record and address insert here
            for(String str:csvLines){
                
                String[] csvRecordData = csvObj2.readLine();
                
                
                if(csvRecordData != null && csvRecordData.size() > 0){
                    ChannelWraper obj = getTypeAndCode(csvRecordData[0],codeSet);
                    String Customer_Type = '';
                    String distCode = '';
                    if(obj != null){
                        Customer_Type = obj.Customer_Type;
                        distCode = obj.distCode;
                    }
                    
                    if(csvRecordData[12] != null && String.isNotBlank(csvRecordData[12])){
                        //Insert Address here
                        Address__c addrObj = new Address__c();                        
                        if(addressMapExisting.containsKey(csvRecordData[12])){
                            System.debug('Address found '+csvRecordData[12]);
                            addrObj = addressMapExisting.get(csvRecordData[12]);
                            addrObj.Id = addressMapExisting.get(csvRecordData[12]).Id;
                        } 
                        addrObj.recordTypeId = recordtypeId;
                        addrObj.Name = csvRecordData[16]+' '+csvRecordData[17];
                        addrObj.Customer_Code_SOP__c = csvRecordData[13];
                        addrObj.Customer_Code_SHP__c = csvRecordData[12];
                        
                        addrObj.Shipping_Country__c = csvRecordData[18].length() > 20 ? csvRecordData[18].substring(0,19) : csvRecordData[18];
                        addrObj.Shipping_City__c = csvRecordData[16].length() > 20 ? csvRecordData[16].substring(0,19) : csvRecordData[16] ;
                        addrObj.Shipping_State_Province__c = csvRecordData[17].length() > 20 ? csvRecordData[17].substring(0,19) : csvRecordData[17];
                        addrObj.Shipping_Street__c = csvRecordData[14]+' '+csvRecordData[15];
                        addrObj.Shipping_Zip_Postal_Code__c = csvRecordData[19].length() > 20 ? csvRecordData[19].substring(0,19) : csvRecordData[19];
                        if(csvRecordData[13] != null && String.isNotBlank(csvRecordData[13]) && parentToUpsert.containsKey(csvRecordData[13]) && !csvRecordData[0].equalsIgnoreCase(csvRecordData[13].remove('_SP'))){
                            addrObj.Account__c = parentToUpsert.get(csvRecordData[13]).Id;
                        }else if(csvRecordData[13] != null && String.isNotBlank(csvRecordData[13]) && csvRecordData[13].containsIgnoreCase('_SP') && parentToUpsert.containsKey(csvRecordData[13].remove('_SP'))){
                            addrObj.Account__c = parentToUpsert.get(csvRecordData[13].remove('_SP')).Id;
                        }else{
                            addrObj.Account__c = null;
                        } 
                        
                        addressMapToUpsert.put(csvRecordData[12],addrObj);
                    }
                    
                    Account newAccount = new Account();
                    
                    if(csvRecordData[0] != null && String.isNotBlank(csvRecordData[0])  && !parentToUpsert.containsKey(csvRecordData[0]) ){
                        //Insert childs here
                        
                        if(mapAcc.containsKey(csvRecordData[0])){
                            //List of accounts to update                    
                            /*         for(Account a:mapAcc.values()){
if(a.Customer_Code__c == csvRecordData[0]){
a.Customer_Code__c = csvRecordData[0];
a.Name = csvRecordData[1];
a.Phone = csvRecordData[4];
a.Service_Tax_Number__c = serviceTax;
a.Customer_Code_SOP__c = cstNmber;
if(parentToUpsert.containsKey(csvRecordData[13]) && !csvRecordData[0].equalsIgnoreCase(cstNmber.remove('_SP'))){
a.ParentId = parentToUpsert.get(csvRecordData[13]).Id;
}else if(String.isNotBlank(cstNmber) && cstNmber.containsIgnoreCase('_SP') && parentToUpsert.containsKey(cstNmber.remove('_SP')) && !csvRecordData[0].equalsIgnoreCase(cstNmber.remove('_SP'))  ){
a.ParentId = parentToUpsert.get(cstNmber.remove('_SP')).Id;
}

a.BillingState = csvRecordData[8];
a.BillingCity = csvRecordData[7];
a.BillingCountry = csvRecordData[9];
a.ShippingCity = csvRecordData[16];
a.ShippingCountry = csvRecordData[18];
a.ShippingState = csvRecordData[17];
a.ShippingCity = csvRecordData[16].length() > 20 ? csvRecordData[16].substring(0,19) : csvRecordData[16] ;
a.ShippingCountry = csvRecordData[18].length() > 20 ? csvRecordData[18].substring(0,19) : csvRecordData[18];
a.ShippingState = csvRecordData[17].length() > 20 ? csvRecordData[17].substring(0,19) : csvRecordData[17];
a.ShippingPostalCode = csvRecordData[19].length() > 20 ? csvRecordData[19].substring(0,19) : csvRecordData[19];
if(String.isNotBlank(distCode)){
a.Customer_Type__c = Customer_Type;
a.Distrbution_Channel__c = distCode;
}
//a.BillingPostalCode = csvRecordData[10];    
childAccUpdate.put(a.Customer_Code__c,a);
}
}
*/
                            
                            newAccount = mapAcc.get(csvRecordData[0]);   
                        }
                        newAccount.Customer_Code__c = csvRecordData[0];
                        //a.Email_Address__c = csvRecordData[16] +' '+csvRecordData[3]; 
                        newAccount.Name = csvRecordData[1];
                        newAccount.Phone = csvRecordData[4];
                        newAccount.BillingState = csvRecordData[8];
                        newAccount.BillingStreet = csvRecordData[5].length() > 20 ? csvRecordData[5].substring(0,19) : csvRecordData[5];
                        newAccount.BillingCity = csvRecordData[7];
                        
                        String street = csvRecordData[14] +' '+csvRecordData[15];
                        newAccount.Shippingstreet =   street.length() > 255 ? street.substring(0,254) : street;
                        newAccount.ShippingState = csvRecordData[17];
                        newAccount.ShippingCity = csvRecordData[16].length() > 20 ? csvRecordData[16].substring(0,19) : csvRecordData[16];
                        newAccount.ShippingCountry = csvRecordData[18].length() > 20 ? csvRecordData[18].substring(0,19) : csvRecordData[18];
                        newAccount.ShippingState = csvRecordData[17].length() > 20 ? csvRecordData[17].substring(0,19) : csvRecordData[17];
                        newAccount.ShippingPostalCode = csvRecordData[19].length() > 20 ? csvRecordData[19].substring(0,19) : csvRecordData[19];
                        
                        
                        newAccount.Service_Tax_Number__c = csvRecordData[12];
                        newAccount.Customer_Code_SOP__c = csvRecordData[13];
                        if(csvRecordData[13] != null && String.isNotBlank(csvRecordData[13]) && parentToUpsert.containsKey(csvRecordData[13]) && !csvRecordData[0].equalsIgnoreCase(csvRecordData[13].remove('_SP'))){
                            newAccount.ParentId = parentToUpsert.get(csvRecordData[13]).Id;
                        }else if(csvRecordData[13] != null && String.isNotBlank(csvRecordData[13]) && csvRecordData[13].containsIgnoreCase('_SP') && parentToUpsert.containsKey(csvRecordData[13].remove('_SP'))){
                            newAccount.ParentId = parentToUpsert.get(csvRecordData[13].remove('_SP')).Id;
                        }
                        if(String.isNotBlank(distCode)){
                            newAccount.Customer_Type__c = Customer_Type;
                            newAccount.Distrbution_Channel__c = distCode;
                        }
                        newAccount.BillingCountry = csvRecordData[9];
                        //a.BillingPostalCode = csvRecordData[10];                             
                        
                        childAccInsert.put(csvRecordData[0],newAccount);
                        
                    }
                }
            }
            System.debug('**** mapAcc '+mapAcc);
            
            Upsert childAccInsert.values();
            System.debug('Acc Upsert '+JSON.serialize(childAccInsert));
            //Update childAccUpdate.values();
            
            System.debug('addressMapToUpsert '+JSON.serialize(addressMapToUpsert));
            if(!addressMapToUpsert.values().isEmpty()){
                upsert addressMapToUpsert.values();
            }
            
            SSSCsvReader csvObj3 = new SSSCsvReader(csvString);
            
            //insert contacts records
            for(String str:csvLines){
                String[] csvRecordData = csvObj3.readLine();                
                
                if(String.isNotBlank(csvRecordData[3]) && csvRecordData.size() > 3 && csvRecordData[3] != null){
                    Contact conObj = new Contact();                    
                    Account newAccount;
                    if(childAccUpdate.containsKey(csvRecordData[0])){
                        newAccount = childAccUpdate.get(csvRecordData[0]);
                    }if(childAccInsert.containsKey(csvRecordData[0])){
                        newAccount = childAccInsert.get(csvRecordData[0]);                        
                    }if(parentToUpsert.containsKey(csvRecordData[0])){
                        newAccount = parentToUpsert.get(csvRecordData[0]);                        
                    }
                    List<String>names = new List<String>();
                    conObj.LastName = csvRecordData[2];
                    if(csvRecordData[2] != null){
                        if(csvRecordData[2].contains(' ')){
                            names = csvRecordData[2].split(' ');
                            conObj.FirstName = names[0];
                            if(names.size() > 1){
                                conObj.LastName = names[1];
                            }else{
                                conObj.LastName = csvRecordData[2];                            
                            }
                        }else{
                            conObj.LastName = csvRecordData[2];
                        }
                    }
                    
                    if(newAccount != null && conObj.LastName != null){
                        conObj.AccountId = newAccount.Id;
                        if(newAccount.contacts.isEmpty()){
                            conObj.Email = csvRecordData[3] != null && String.isNotBlank(csvRecordData[3]) && csvRecordData[3].contains('@') ? csvRecordData[3] : '';
                            conObj.Phone = csvRecordData[4];
                        }else{
                            conObj = newAccount.contacts[0];
                            if(csvRecordData[2].contains(' ')){
                                names = csvRecordData[2].split(' ');
                                conObj.FirstName = names[0];
                                if(names.size() > 1){
                                    conObj.LastName = names[1];
                                }else{
                                    conObj.LastName = csvRecordData[2];                            
                                }
                            }else{
                                conObj.LastName = csvRecordData[2];
                            }
                            conObj.Email = csvRecordData[3] != null && String.isNotBlank(csvRecordData[3]) && csvRecordData[3].contains('@') ? csvRecordData[3] : '';
                            conObj.Phone = csvRecordData[4];
                        }
                        contactToInseret.add(conObj);
                    }
                }
            }
            
            if(!contactToInseret.isEmpty()){
                upsert contactToInseret;
            }
        }catch(CalloutException ex){
            System.debug('Exception '+ ex.getMessage());
        }
        
    }
    public Class ChannelWraper{
        String Customer_Type{get;set;}
        String distCode{get;set;}        
    }
    public static ChannelWraper getTypeAndCode(String customerCode,Set<String>codeSet){
        ChannelWraper wrapObj = new ChannelWraper();
        String channelCode = '';
        String Customer_Type = '';
        String distCode = '';
        //code block to set Customer type
        if(customerCode != null && customerCode.contains('_')){
            List<String>codes = customerCode.split('_');
            if(!codes.isEMpty() && codes[1] != null){
                channelCode = codes[1];
            }
        }
        
        //dist channel setting
        if(codeSet.contains(channelCode)){
            if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('61')){
                wrapObj.Customer_Type = 'Distributor';
                wrapObj.distCode = '61';
            }else if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('62')){
                wrapObj.Customer_Type = 'Retailer';
                wrapObj.distCode = '62';
            }else if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('63')){
                wrapObj.Customer_Type = 'LFS';
                wrapObj.distCode = '63';
            }else if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('65')){
                wrapObj.Customer_Type = 'Online Sales-eCommerce';
                wrapObj.distCode = '65';
            }else if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('67')){
                wrapObj.Customer_Type = 'Direct'; 
                wrapObj.distCode = '67';
            }else if(String.isNotBlank(channelCode) && channelCode.equalsIgnoreCase('68')){
                wrapObj.Customer_Type = 'B2B';
                wrapObj.distCode = '68';
            }
            
        }
        return wrapObj;
    }
    
    public class wrappercls{
        String CustomerCode{get;set;}
        String CustomerName{get;set;}
        String ContactName{get;set;}
        String ContactEmail{get;set;}
        String ContactPhone{get;set;}
        String BillingAddressLine1{get;set;}
        String BillingAddressLine2{get;set;}
        String BillingAddressCity{get;set;}
        String BillingAddressState{get;set;}
        String BillingAddressCountry{get;set;}
        String BillingAddressPincode{get;set;}
        String BillingAddressPhone{get;set;}
        String ServiceTaxNumber{get;set;}
        String CSTNumber{get;set;}
        String ShippingAddressLine1{get;set;}
        String ShippingAddressLine2{get;set;}
        String ShippingAddressCity{get;set;}
        String ShippingAddressState{get;set;}
        String ShippingAddressCountry{get;set;}
        String ShippingAddressPincode{get;set;}
        String ShippingAddressPhone{get;set;}
    }
}