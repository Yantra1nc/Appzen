@isTest
global class UniAuthHttpMockCallout implements HttpCalloutMock{
 global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"access_token": "11e3a3e9-8892-4f58-9fdd-c8302867285b", "token_type": "bearer", "refresh_token": "3b0a42f7-8fed-4453-b338-e84e19c60626","expires_in": 35506, "scope": "read trust write"}');
        response.setStatusCode(200);
        return response; 
    }
}