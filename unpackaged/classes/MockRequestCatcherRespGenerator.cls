@isTest
global class MockRequestCatcherRespGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"OK"}');
        res.setStatusCode(200);
        return res;
    }
}