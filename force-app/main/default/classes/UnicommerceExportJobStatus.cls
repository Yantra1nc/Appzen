public class UnicommerceExportJobStatus implements Queueable,Database.AllowsCallouts{
    
    public static String token;
    public String jobCode;
    public static String ENDPOINT;
    public List<String> csvFileLines{get;set;}
    
    
    public UnicommerceExportJobStatus(String jobCodeFromExJob){
        System.debug('Constructor'+jobCodeFromExJob); 
        this.jobCode = jobCodeFromExJob;
        
    }
    
    public void execute(QueueableContext qc){
        token = UnicommerceAuthentication.getAuthenticationToken();
        UnicommerceExportJobStatus__c custSettings = UnicommerceExportJobStatus__c.getValues('JobStatusUrl');
        ENDPOINT = custSettings.ExportJobStatus__c;
        Map<String,Object> mapResponse = new Map<String,Object>();
        System.debug('Token '+token);
        System.debug('JOB '+jobCode);
        System.debug('ENDPOINT '+ENDPOINT);
        try{
            if(token != null && jobCode != null){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+token);
                req.setMethod('POST');
                req.setEndpoint(ENDPOINT);
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
                        //saveCSVToSF((String)mapResponse.get('filePath'));
                        //List<String> lstSkuCodes = calloutForCSV((String)mapResponse.get('filePath')); 
                        System.enqueueJob(new UnicommerceGetExportCsv((String)mapResponse.get('filePath')));                      
                    }
                }
            }
            System.debug('FilePath '+(String)mapResponse.get('filePath'));
            
            
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            System.debug('Exception '+ex.getStackTraceString());
            System.debug('Exception '+ex.getLineNumber());
        }
    }
    
    
    
   
    
}