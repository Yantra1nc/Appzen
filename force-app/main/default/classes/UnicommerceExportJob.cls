public class UnicommerceExportJob implements Queueable,Database.AllowsCallouts{
    public static String ENDPOINT;
    public static String token;
    public static Map<String,Object> mapResponse;
   
    public void execute(QueueableContext qc){
        token = UnicommerceAuthentication.getAuthenticationToken();
        UnicommerceExportJob__c custSettings = UnicommerceExportJob__c.getValues('ExportJobApi');
        ENDPOINT = custSettings.ExportJob__c;  
        String jobCode = createExportJob(token);
        try{
            System.enqueueJob(new UnicommerceExportJobStatus(jobCode));
        }catch(exception e){
            System.debug('Error :'+e.getMessage()+' line : '+e.getLineNumber());
        }
    }
    
    //Callout to create an export job in Unicommerce
    public static String createExportJob(String token){
        try{
            if(token != null){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+ token);
                req.setHeader('Facility', 'Warehouse');//Custom setting 
                req.setMethod('POST');
                req.setEndpoint(ENDPOINT);
                String reqBody = '{'+
                    '"exportJobTypeName": "Sale Orders",'+
                    '"exportColums": ['+
                    '"soicode","displayorderCode","reversePickupCode","reversePickupCreatedDate","reversePickupReason","notificationEmail","notificationMobile",'+
                    '"requireCustomization",'+
                    '"cod","shippingAddressId","category","invoiceCode","invoiceCreated","shippingAddressName","shippingAddressLine1","shippingAddressLine2",'+
                    '"shippingAddressCity","shippingAddressState","shippingAddressCountry","shippingAddressPincode","shippingAddressPhone","billingAddressId",'+
                    '"billingAddressName","billingAddressLine1","billingAddressLine2","billingAddressCity","billingAddressState","billingAddressCountry",'+
                    '"billingAddressPincode","billingAddressPhone","shippingMethod","skuCode","channelProductId","itemTypeName","itemTypeColor","itemTypeSize",'+
                    '"itemTypeBrand","channel","itemRequireCustomization","giftWrap","giftMessage","hsnCode","maxRetailPrice","totalPrice","sellingPrice","costPrice",'+
                    '"prepaidAmount","subtotal","discount","gstTaxTypeCode","cgst","igst","sgst","utgst","cess","cgstrate","igstrate","sgstrate","utgstrate","cessrate",'+
                    '"tax","taxValue","voucherCode","shippingCharges","shippingMethodCharges","cashOnDeliveryCharges","giftWrapCharges","packetNumber",'+
                    '"displayOrderDateTime","saleOrderCode","onhold","status","priority","currency","currencyConversionRate","SoiStatus","cancellationReason",'+
                    '"shippingProvider","shippingArrangedBy","ShippingPackageCode","ShippingPackageCreationDate","shippingPackageStatusCode",'+
                    '"shippingPackageTypeCode","shippingPackageLength","shippingPackageWidth","shippingPackageHeight","deliveryTime","TrackingNumber",'+
                    '"dispatchDate","facility","returnedDate","returnReason","created","updated","combinationIdentifier","combinationDescription","transferPrice",'+
                    '"itemCode","imei","actualWeight","gsttin","Cgsttin","tin","paymentInstrc"'+
                    '],'+
                    '"exportFilters": ['+
                    '{'+
                    '"id": "addedOn",'+
                    '"dateRange": {'+
                    '"start": "2020-10-01T00:00:00.000Z",'+
                    '"end": "2020-10-04T00:00:00.000Z",'+
                    '"textRange": "TODAY"}'+
                    '},'+
                    
                    '{'+
                    '"id": "dispatchedOn",'+ 
                    '"dateRange": {'+
                    '"start": "2020-10-02T00:00:00.000Z",'+ 
                    '"end": "2020-10-01T00:00:00.000Z"}'+
                    '},'+
                    
                    '{"id":"status","selectedValues":["CREATED","FULFILLABLE","UNFULFILLABLE","CANCELLED","DISPATCHED","DELIVERED","REPLACED","RESHIPPED","UNABLE_TO_PURCHASE","ALTERNATE_SUGGESTED","ALTERNATE_ACCEPTED","LOCATION_NOT_SERVICEABLE","MANIFESTED","PICKING_FOR_STAGING","STAGED","PICKING_FOR_INVOICING"]}'+
                    '],'+
                    '"frequency":"ONETIME"'+
                    '}';
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
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        } 
        return (String)mapResponse.get('jobCode');
    }
}