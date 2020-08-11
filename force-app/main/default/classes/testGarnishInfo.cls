@isTest

private class testGarnishInfo {

    static testMethod void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new MockGenerator());
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
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/Garnish/Mozzarella';       

        Test.startTest();
          List<contact> testCon=GarnishInfo.getContactByGarnish();
          System.debug(testCon);
        Test.stopTest();
   }

}