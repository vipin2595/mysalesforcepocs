public class BillingCallout {
    @future(callout=true)
    public static void makeCallout(Set<Id> conId) {
        //Requery all the conacts
        list<Contact> cons = [SELECT Id,AccountId,Email,FirstName,LastName FROM Contact WHERE Id IN :conId];
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        String endpoint = 'https://demo5326524.mockable.io/contact';
        req.setEndPoint(endpoint);
       
        JSONGenerator gen = JSON.createGenerator(true);  
        for(Contact c:cons){
            gen.writeStartArray();
            gen.writeStartObject();      
            gen.writeStringField('id ', c.Id);
            gen.writeStringField('accountId',c.AccountId);
            gen.writeStringField('email',c.Email);
            gen.writeStringField('firstname',c.FirstName);
            gen.writeStringField('lastname',c.LastName);
            gen.writeEndObject();
            gen.writeEndArray();
        }
    
        String jsonS = gen.getAsString();
        
        req.setMethod('POST');
        req.setBody(jsonS);
        req.setCompressed(true); // otherwise we hit a limit of 32000

        try {
            System.debug(req.getBody());
            res = http.send(req);
            System.debug(res.getStatusCode());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.getStatusCode());
            System.debug(res.toString());
        }
    }
}