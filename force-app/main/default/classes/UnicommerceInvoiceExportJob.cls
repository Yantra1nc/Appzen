public class UnicommerceInvoiceExportJob implements Schedulable {
    public static String ENDPOINT;
    public static String token;
    public static Map<String,Object> mapResponse;
    
    public void execute(SchedulableContext context){
        createExportJobInvoice();
    }
    
    @future(callout = true)
    public static void createExportJobInvoice(){
        UnicommerceExportJob__c custSettings = UnicommerceExportJob__c.getValues('ExportJobApi');
        ENDPOINT = custSettings.ExportJob__c;  
        
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
                    '"id": "dateCreatedRange",'+
                    '"dateRange": {'+                                    
                    '"textRange": "TODAY"}'+
                    '}],'+
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
        if(mapResponse != null && mapResponse.containsKey('jobCode')){
            if(token != null){
                System.enqueueJob(new UnicommerceInvoiceExportStatus(String.valueOf(mapResponse.get('jobCode')),token));
            }
        }
    }
}