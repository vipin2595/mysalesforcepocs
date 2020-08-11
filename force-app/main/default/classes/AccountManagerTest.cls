/*@isTest
Private class AccountManagerTest {
    private static testmethod void testbyaccountid(){
        id requestid = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri ='https://na85.salesforce.com/services/apexrest/Accounts/'+requestid+'/Contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account[] thisaccount = AccountManager.getAccount();

    }
    static Id createTestRecord(){
        Account TestAcc = new Account(Name='Test record');
        insert TestAcc;
        Contact TestCon= new Contact(LastName='Test',AccountId = TestAcc.id);
        return TestAcc.Id;
    }
    
}*/
@isTest
private class AccountManagerTest {
  @isTest
     static void test(){
         Account Acc=new Account();
         acc.Name='test';
         insert acc;
         Contact con=new Contact();
         con.LastName='test';
         con.FirstName='test';
         con.Accountid=acc.id;
         insert con;
        RestRequest request =new RestRequest();
        request.requestURI='https://na85.salesforce.com/services/apexrest/Accounts/'+acc.id+'/contacts'; 
         request.httpMethod='GET';
         RestContext.request=request;
         Account accs=AccountManager.getAccount();
    }
}