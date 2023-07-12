public class AlertAPITesting {    
    
    @future (callout = true)
        @TestVisible
        public static void makeCallout(){
             String endpoint;        
         //    Batch_Sync_Audit_Log__c bsal = new Batch_Sync_Audit_Log__c();
             Opportunity opp = new Opportunity();
             try {                  
                  HttpRequest req = new HttpRequest();
                  HttpResponse res = new HttpResponse();
                  Http http = new Http();
                  endpoint = 'https://demostaging.unicommerce.com/services/rest/v1/oms/saleOrder/create';
        
                  req.setHeader('Authorization', 'bearer 12c12cb3-25a6-4226-9597-546d7ec5401a');
                  req.setHeader('Content-Type', 'application/json');
                  req.setEndpoint(endpoint);
                  req.setMethod('GET');
                  req.setCompressed(true);
                  if (!Test.isRunningTest()) {      
                            res = http.send(req);
                            String sJson = res.getBody();
                            System.debug('Str:' + sJson);
                       //     opp.Response_Received__c = sJson;
                            parseResponse(sJson);
                  }             
              } catch (Exception e) {         
                    System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
              //      opp.Error_Message__c = e.getMessage();           
              } finally {
                      insert opp;
              }
        }
        private static void parseResponse(String jsonInput) {
            JSONParser parser = JSON.createParser(jsonInput);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'name' && parser.getText() == 'date' 
                   && parser.getText() == 'Account' ) {
                     
                    parser.nextToken();
                   
                    String oppName = parser.getText();
                    
                    Date closedate = parser.getDateValue();
                       String accountname = parser.getText();
           
                    createSalesOrder(oppName, closedate, accountname);
                    
                }
            }
        } 
        
        private static void createSalesOrder(String name, Date expirydate, String customer) {
            
            Opportunity o = new Opportunity();
            o.Name = name;
            o.StageName = 'Draft';
            o.CloseDate = expirydate;
            o.Customer__c = customer;
            insert o;
        } 
    }