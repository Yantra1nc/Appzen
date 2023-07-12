@isTest
global class UniInventoryMockCallout implements HttpCalloutMock{
    
 global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"successful":true,"message":null,"errors":[],"warnings":[],"inventorySnapshots":[{"itemTypeSKU":"test","inventory":0,"openSale":22,"openPurchase":0,"putawayPending":0,"inventoryBlocked":0,"pendingStockTransfer":0,"vendorInventory":0,"virtualInventory":0,"pendingInventoryAssessment":1}]}');
        response.setStatusCode(200);
        return response; 
    }
}