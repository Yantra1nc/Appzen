Global class UnicommerceCustomerMaster implements Schedulable{
    
    public static String ENDPOINT;
    public static String token;
    public static Map<String,Object> mapResponse;
    
    public void execute(SchedulableContext context){
        createExportJobCustomerMaster();
    }
    
    @future(callout=true)    
    public static void createExportJobCustomerMaster(){
        if(!Test.isRunningTest()){
            token = UnicommerceAuthentication.getAuthenticationToken();
        }
        else{
            token = 'acjascaisbciabsicbasibc';
        }
        UnicommerceExportJob__c custSettings = UnicommerceExportJob__c.getValues('ExportJobApi');
        ENDPOINT = custSettings.ExportJob__c;  
        if(token != null){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setHeader('Facility', 'indocount-test');//Custom setting 
            req.setMethod('POST');
            req.setEndpoint(ENDPOINT);
            String reqBody = '{'+
                '"exportJobTypeName": "Customer Report New",'+
                '"exportColums": ['+
                '"customerCode","customerName","partyContactName","partyContactEmail","partyContactPhone","address1","address2","city",'+ 
                '"state","country","pincode","phone","stin","cst","address11","address21","city1","state1","country1","pincode1","phone1"'+
                '],'+                    
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
            System.debug('response -> '+res.getBody());
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
        if(token != null && mapResponse.containsKey('jobCode')){
            String jobCode = string.valueOf(mapResponse.get('jobCode'));
            System.debug('JOb Code '+ jobCode);
            System.enqueueJob(new UnicommerceCustomerMasterExportStatus(jobCode,token));
        }        
    }   
}