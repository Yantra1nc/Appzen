public class UnicommerceInvoiceExportS {
    public static String ENDPOINT;
    public static String token;   
    public static Map<String,Object> mapResponse;
    
    @future(callout = true)
    public static void createExportJobInvoice(){
        UnicommerceExportJob__c custSettings = UnicommerceExportJob__c.getValues('ExportJobApi');
        ENDPOINT = custSettings.ExportJob__c;  
        System.debug('hii');
        if(!Test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }
        else{
            token = '987tdcfhjkmnbhbfygjh';
        }
        try{
            if(token != null){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+ token);
                req.setHeader('Facility', 'indocount-test');//Custom setting 
                req.setMethod('POST');
                req.setEndpoint(ENDPOINT);
                String reqBody = '{'+
                    '"exportJobTypeName": "Invoice",'+
                    '"exportColums": ['+
                    '"orderCode","invoiceCode","invoiceDate","shippingPackageCode",'+ 
                    '"skuCode",'+
                    '"quantity","invoiceTax","invoiceTotal",'+
                    '"cgst","igst","sgst","utgst",'+
                    '"cgstrate","igstrate","sgstrate","utgstrate","TCSAmount"'+  // while deploying to production we need the custom fields                   
                    '],'+ 
                    '"exportFilters": ['+
                    '{'+
                    '"id": "orderCode",'+
         '"text": "orderCode",'+
         '"selectedValue": "SO-911_1",'+
                    '"frequency":"ONETIME"'+
                    '}';
                System.debug(reqBody);
                req.setBody(reqBody);
                HttpResponse res;
                if(!Test.isRunningTest()){
                    res = http.send(req);
                }else{
                    res = new HttpResponse();
                    res.setStatusCode(200);
                    res.setBody('{"successful": true, "jobCode": "1231231aas","code":"101","description":"abcd test","message":"test msg"}');
                    
                }
                
                System.debug(JSON.deserializeUntyped(res.getBody()));
                
                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                if(res.getStatusCode() == 200){
                    if(mapResponse.get('successful') == true){
                        System.debug('JobCode '+mapResponse.get('jobCode'));
                        string jobCode;
                        JobCode = string.Valueof(mapResponse.get('jobCode')) ;
                        createFilePathInvoice(jobCode ,token);
                        
                    }else{
                        Map<String,Object> mapError = (Map<String,Object>)mapResponse.get('errors');
                        System.debug('Error Code '+mapError.get('code'));
                        System.debug('Error Description '+mapError.get('description'));
                        System.debug('Error Message'+mapError.get('message'));
                    }
                }
            }
            
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage()+' -> '+ex.getLineNumber());
        } 
        System.debug('***** mapResponse '+mapResponse);
        
    }
    
    
    public static String createFilePathInvoice(String jobCode,String token){
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
                    else{
                        while(mapResponse.get('successful') == false){
                            response = http.send(req);
                            if(response.getStatusCode() == 200){
                                System.debug('response.getBody()' +response.getBody());
                                mapResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                                
                                if(mapResponse.get('successful') == true && mapResponse.get('status') == 'COMPLETE'){
                                    System.debug('FilePath '+mapResponse.get('filePath')); 
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            System.debug('FilePath '+(String)mapResponse.get('filePath'));
            if(string.isNotBlank((String)mapResponse.get('filePath'))){
               calloutForCSV((String)mapResponse.get('filePath')); 
            }
            
            
            
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            System.debug('Exception '+ex.getStackTraceString());
            System.debug('Exception '+ex.getLineNumber());
        }
        return (String)mapResponse.get('filePath');
    }
    
     public static void calloutForCSV(String fileUrl){
        String result;
        List<String> lstskuCodes = new List<String>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/csv');      
        req.setMethod('GET');
        req.setEndpoint(fileUrl);
        try{
            HttpResponse res = http.send(req);                       
            Blob csvBlob = res.getBodyAsBlob(); 
            System.debug('csvBlob '+csvBlob);
            String csvString = csvBlob.toString();
            System.debug('csvString '+csvString);     
            
            //get iterable string 
            SSSCsvReader rowIterator = new SSSCsvReader(csvString,'\n',true);
            Iterator<String> iterator = rowIterator.iterator();
            SSSCsvReader prodMaster = new SSSCsvReader(csvString);
            
            //String[] csvLines = (String[])rowIterator.iterator();//csvString.split('\n');
            //System.debug('csvLines: ' + csvLines);
            while (iterator.hasNext()) {
                String str = iterator.next();
                System.debug('line: ' + str);
                String[] csvRecordData = prodMaster.readLine();
                if(csvRecordData != null && csvRecordData[0] != null){
                    System.debug('Data '+csvRecordData[0]);
                  //  lstskuCodes.add(csvRecordData[1]);
                }
            }
            System.debug('Sku Codes '+ lstskuCodes);
            
        }catch(CalloutException ex){
            System.debug('Exception '+ ex.getMessage());
        }
        //return lstskuCodes;
    }
}