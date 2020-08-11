@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    // implement http mock callout
    global HttpResponse respond(HttpRequest request){
        
    	// Create a fake response
		HttpResponse response1 = new HttpResponse();
        response1.setHeader('Content-Type', 'application/json');
		response1.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]');
        response1.setStatusCode(200);
        return response1;
    }
}