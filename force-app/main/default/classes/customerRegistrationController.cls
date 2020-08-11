public class customerRegistrationController {
    
    public Account objA {get; set;}
    
    public customerRegistrationController() {
        objA = new Account();
    }
    
    public void doSave(){
        // connection
        
        String endpoint = 'https://viipinkommidilwcpoc-dev-ed.my.salesforce.com/services/oauth2/token?grant_type=password&client_id=3MVG9zlTNB8o8BA2Qsmf86bYOQf75VUXis52srtGDkUeOU2fMPvbBT_FmHuMJWi3gznAjxUjU0Pbh6gxP5cAL&client_secret=151AC8AB12ADB95C97AAB62DD402CD4A728692A1E030250182CA3BCD4C1A1E7F&username=kvipin2595@gmail.com&password=6gAJ@sqmF!kp4rDNaDLIMDjgCv7WrvSoNBbunBK';
        
        // Satrt - 1 send request and get Acces token in the body
        HTTPRequest request = new HTTPRequest();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        HTTP HttpParam = new HTTP();
        
        HTTPResponse response= HttpParam.send(request);
        System.debug('Str Response is ---->'+response.getBody());
        String responseVal = response.getBody();
        // End - 1 

        // Start - 2 parse the acess token
        string accsToken = '';
            JSONParser parser1 = JSON.createParser(responseVal); 
            while (parser1.nextToken() != null) {
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'access_token')) {
                    parser1.nextToken();
                    accsToken = parser1.getText();
                }
            }
        // End - 2
        System.debug('VV accsToken -->'+accsToken);
        
        // Start - 3 After getting access token make the request in the source org
        String EndPointURLforREST = 'https://viipinkommidilwcpoc-dev-ed.my.salesforce.com/services/apexrest/CustomerRecords';
        
        request = new HTTPRequest();
        request.setEndPoint(EndPointURLforREST);
        request.setMethod('POST');
        request.setHeader('content-type','application/json');
        String jSONreq = '{\"name\":\"'+objA.Name+'\",\"phone\":\"'+objA.Phone+'\"}';
        request.setBody(JSONreq);
        request.setHeader('Authorization', 'OAuth '+accsToken);
        response = HttpParam.send(request);
        
        System.debug('Response is -->'+response.getBody());
                // Passing the parameter to source org
        // End - 3
        
        if(response.getStatus() == '200' && response.getBody() != null){
            
            // perform DML
        }
    }

}