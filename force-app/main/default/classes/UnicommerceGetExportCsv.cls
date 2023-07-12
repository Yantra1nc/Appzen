public class UnicommerceGetExportCsv implements Queueable,Database.AllowsCallouts{
    
    public String fileUrl;
    public String token;
    List<String> lstSkuCodesNew = new List<String>();
    public UnicommerceGetExportCsv(String fileUrl){
        this.fileUrl = fileUrl;
    }
    
	public void execute(QueueableContext qc){
        token = UnicommerceAuthentication.getAuthenticationToken();        
        List<String> lstSkuCodes = UnicommerceGetExportCsv.calloutForCSV(fileUrl);
        System.debug('List sku codes '+ lstSkuCodes);
        for(Integer i=0;i<lstSkuCodes.size();i++){
            if(i!=0){
                lstSkuCodesNew.add(lstSkuCodes[i]);
            }
        }
        System.debug('skuCodes '+lstSkuCodesNew);
        String jobId = database.executeBatch(new UnicommerceProductDetailsBatch(token,lstSkuCodesNew), 80);        
    }
    
     public static List<String> calloutForCSV(String fileUrl){
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
                if(csvRecordData != null && csvRecordData[1] != null){
                    System.debug('Data '+csvRecordData[1]);
                    lstskuCodes.add(csvRecordData[1]);
                }
            }
            System.debug('Sku Codes '+ lstskuCodes);
            
        }catch(CalloutException ex){
            System.debug('Exception '+ ex.getMessage());
        }
        return lstskuCodes;
    }
}