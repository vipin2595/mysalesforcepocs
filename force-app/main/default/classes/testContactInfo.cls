@isTest
public class testContactInfo {
    static testMethod void test(){
    
        Account acc=new Account(Name='test');
        insert acc;
        Contact c=new Contact(AccountId=acc.Id,FirstName='First',LastName='Last',Email='abc@def.com');
        insert c;
        Garnish__c g= new Garnish__c(Name='Mozzarella',Calories__c=250,Color__c='Brown',Liquid__c=false,Origin__c='Brazil'); 
        insert g;
        junc__c j = new junc__c(Contact__c=c.Id,garnish__c=g.Id);
        insert j;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ContactInfo';       
    }
}