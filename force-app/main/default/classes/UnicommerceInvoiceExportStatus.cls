public class UnicommerceInvoiceExportStatus implements Queueable,Database.AllowsCallouts{
	public String jobCode;
    public String token;    
    public static Map<String,Id> mapOpp = new Map<String,Id>();
    public static List<Invoice__c> lstInvoices = new List<Invoice__c>(); 
    public static List<InvoiceItemWrapper> lstWrapper = new List<InvoiceItemWrapper>();
    public static Map<String,InvoiceItemWrapper> mapInvoice= new Map<String,InvoiceItemWrapper>();
    
    public UnicommerceInvoiceExportStatus(String jobCode,String token){
        this.jobCode = jobCode;
        this.token = token;
    }
    
    public void execute(QueueableContext qc){
        List<Id> lstInvIds = new List<Id>();
        Map<Id,List<Invoice__c>> mapInvoices = new Map<Id,List<Invoice__c>>();
         for(Opportunity opp:[Select Id,Name,OrderNumUniware__c,Uniware_Internal_SO_No__c from Opportunity where (StageName != 'Cancelled' OR StageName != 'Order Rejected') and Uniware_Internal_SO_No__c != null]){
            mapOpp.put(opp.Uniware_Internal_SO_No__c,opp.Id);
        }
        System.debug('mapOpp '+mapOpp);
        String filePath = createFilePathInvoice(jobCode,token);
        System.debug('Filepath '+filePath);
        List<Invoice__c> lstInv = new List<Invoice__c>();
        if(String.isNotBlank(filePath)){
            lstInv = calloutForCSV(filePath);
        }
        System.debug('lstInv '+lstInv);
      	Set<Invoice__c> output = new Set<Invoice__c>();
    	Set<String> alreadySeen = new Set<String>();        
        List<Invoice__c> lstInvoices = new List<Invoice__c>();
        for(Invoice__c invObj:lstInv){
            if (alreadySeen.contains(invObj.Invoice_No__c))
                output.add(invObj);
                alreadySeen.add(invObj.Invoice_No__c);               
        }
        System.debug(output);
        System.debug(alreadySeen);
        for(Invoice__c inv:lstInv){
            lstInvoices.add(inv);
        }
        System.debug(lstInvoices);
        Database.UpsertResult[]  lstSr =  Database.upsert(lstInvoices,Invoice__c.Invoice_No__c);
        System.debug('lstSr '+lstSr);
        for(Database.UpsertResult sr: lstSr){
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted invoice. Invoice ID: ' + sr.getId());
                lstInvIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
        System.debug(lstWrapper.size());
        List<Invoice_Line_Item__c> lstInvLineItem = new List<Invoice_Line_Item__c>();
        for(Invoice__c inv:[Select Id,Shipping_Package_Code__c from Invoice__c where Id in:lstInvIds]){
            for(InvoiceItemWrapper objWrap:lstWrapper){
               if(objWrap.shippingPackageCode == inv.Shipping_Package_Code__c){
                   
                	Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();                    
                    invLineItem.Invoice__c = inv.Id;
                    invLineItem.SKU_Code__c = objWrap.skuCode;
                    invLineItem.Quantity__c = Decimal.valueOf(objWrap.quantity);
                    invLineItem.Invoice_Tax__c = Decimal.valueOf(objWrap.invoiceTax);
                    invLineItem.Invoice_Total__c = Decimal.valueOf(objWrap.invoiceTotal);
                    invLineItem.CGST__c = Decimal.valueOf(objWrap.cgst);
                    invLineItem.IGST__c = Decimal.valueOf(objWrap.igst);
                    invLineItem.SGST__c = Decimal.valueOf(objWrap.sgst);
                    invLineItem.UTGST__c = Decimal.valueOf(objWrap.utgst);
                    invLineItem.CGST_Rate__c = Decimal.valueOf(objWrap.cgstrate);
                    invLineItem.IGST_Rate__c = Decimal.valueOf(objWrap.igstrate);
                    invLineItem.SGST_Rate__c = Decimal.valueOf(objWrap.sgstrate);
                    invLineItem.UTGST_Rate__c = Decimal.valueOf(objWrap.utgstrate);
                    invLineItem.TCS_Amount__c = Decimal.valueOf(objWrap.tcsAmount);
                    lstInvLineItem.add(invLineItem);
           	   } 
            }
            
        }
        
        Database.insert(lstInvLineItem);
        
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
    
     public static List<Invoice__c> calloutForCSV(String fileUrl){
        String result;
        Set<String> invSet = new Set<String>();
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
            String[] csvLines = csvString.split('\n');
            System.debug('csvLines: ' + csvLines);
            for(String str:csvLines){                
                String[] csvRecordData = str.split(',');
                if(csvRecordData != null){
                    if(csvRecordData[0] == 'Order No'){
                        continue;
                    }    
                    System.debug(mapOpp);
                    for(String s : mapOpp.keySet()){                        
                        if(s == csvRecordData[0]){  
                            
                            Invoice__c inv = new Invoice__c();
                            inv.Opportunity__c = mapOpp.get(s);
                            inv.Order_No_Uniware__c = csvRecordData[0];
                            inv.Invoice_No__c = csvRecordData[1];
                            inv.Invoice_Created_Date__c = DateTime.valueOf(csvRecordData[2]);
                            inv.Shipping_Package_Code__c = csvRecordData[3]; 
                            inv.Amount_Due__c = csvRecordData[7];
                            lstInvoices.add(inv);
                            
                            
                            InvoiceItemWrapper invWrapper = new InvoiceItemWrapper();
                            invWrapper.sfOrderNo = csvRecordData[0];
                            invWrapper.shippingPackageCode = csvRecordData[3];
                            invWrapper.skuCode = csvRecordData[4];
                            invWrapper.quantity = csvRecordData[5];
                            invWrapper.invoiceTax = csvRecordData[6];
                            invWrapper.invoiceTotal = csvRecordData[7];
                            invWrapper.cgst = csvRecordData[8];
                            invWrapper.igst = csvRecordData[9];
                            invWrapper.sgst = csvRecordData[10];
                            invWrapper.utgst = csvRecordData[11];
                            invWrapper.cgstrate = csvRecordData[12];
                            invWrapper.igstrate = csvRecordData[13];
                            invWrapper.sgstrate = csvRecordData[14];
                            invWrapper.utgstrate = csvRecordData[15];
                            invWrapper.tcsAmount = csvRecordData[16];
                            lstWrapper.add(invWrapper);                            
                            mapInvoice.put(csvRecordData[3], invWrapper);
                            System.debug('List Invoices '+lstInvoices);
                        }
                    }
                    
                } 
            }
           System.debug('List Invoices '+lstInvoices);
        }catch(CalloutException ex){
            System.debug('Exception '+ ex.getMessage());
        }
        return lstInvoices;
    }
    
    public class InvoiceItemWrapper{
        public String sfOrderNo{get;set;}
        public String shippingPackageCode{get;set;}
        public String skuCode{get;set;}
        public String quantity{get;set;}
        public String invoiceTax{get;set;}
        public String invoiceTotal{get;set;}
        public String cgst{get;set;}
        public String igst{get;set;}
        public String sgst{get;set;}
        public String utgst{get;set;}
        public String cgstrate{get;set;}
        public String igstrate{get;set;}
        public String sgstrate{get;set;}
        public String utgstrate{get;set;}
        public String tcsAmount{get;set;}
	}
}