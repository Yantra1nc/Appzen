public class UnicommerceExportJobProducts implements Queueable,Database.AllowsCallouts/*,Schedulable*/{
    public static String ENDPOINT;
    public static String token;
    public static Map<String,Object> mapResponse;
    /*
    public void execute(SchedulableContext context){
        System.enqueueJob(new UnicommerceExportJobProducts());
     }
    */
    
    public void execute(QueueableContext qc){
        createExportJob();
    }
    
    //Callout to create an export job in Unicommerce
    @future(callout = true)
    public static void createExportJob(){
        
        //Change added by RT on 20-Jun-22 to avoid Callout exception/ error
        UnicommerceExportJob__c custSettings = UnicommerceExportJob__c.getValues('ExportJobApi');
        ENDPOINT = custSettings.ExportJob__c;  
        token = UnicommerceAuthentication.getAuthenticationToken();

        
        try{
            if(token != null){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+ token);
                req.setHeader('Facility', 'indocount-test');//Custom setting 
                req.setMethod('POST');
                req.setEndpoint(ENDPOINT);
                // '"FABRICCOMPOSITION","FILLING","FILLINGGSM","FINISHTYPE","GSM","PRINTTYPE","PRINTEDSOLID","TYPE","TYPEOFPROCESS","WEAVE"'+
                String reqBody = '{'+
                    '"exportJobTypeName": "Item Master",'+
                    '"exportColums": ['+
                    '"categoryCode","skuCode","itemName","description","MRP","ean","color","size","brand","hsn"'+ 
                    '],'+
                    '"exportFilters": ['+
                        '{'+
                          '"id": "updatedOn",'+
                    '"dateRange": {'+                            
                            '"textRange": "TODAY"}'+
                        '}],'+
                    '"frequency":"ONETIME"'+
                    '}';
                System.debug(reqBody);
                req.setBody(reqBody);
                HttpResponse res = http.send(req);
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
            
        }
        catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        } 
        // return (String)mapResponse.get('jobCode');
        if(mapResponse != null && mapResponse.containsKey('jobCode')){
            String jobCode = String.valueOf(mapResponse.get('jobCode'));
            System.debug('JOb Code '+jobCode);
            System.enqueueJob(new UnicommerceExportJobStatus(jobCode));         
        }
    }
}