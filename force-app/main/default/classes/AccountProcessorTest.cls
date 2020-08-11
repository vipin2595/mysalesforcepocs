@istest
private class AccountProcessorTest {
    @IsTest
    private static void testSendSms() {
        Test.setMock(HttpCalloutMock.class, new mockresponsestest());
        Test.startTest();
        Account acct = new Account(Name='SFDC Account');
        insert acct;
        ID acctID = acct.ID;
        
        // Add a contact to this account.
        Contact con = new Contact(
            FirstName='Joe',
            LastName='Smith',
            Phone='415.555.1212',
            AccountId=acctID);
        insert con;
        Contact con1 = new Contact(
            FirstName='Joe2',
            LastName='Smith2',
            AccountId=acctID);
        insert con1;
        Account acct2 = new Account(Name='SFDC Account');
        insert acct2;
        ID acctID1 = acct2.ID;
        
        // Add a contact to this account.
        Contact con2 = new Contact(
            FirstName='Joe3',
            LastName='Smith3',
            AccountId=acctID1);
        insert con2;
        AccountProcessor.getAccountsid();
        list<id> acntId = new list<id>();
        list<account> accountid = [select id from account];
        for(account acc : accountid){
            acntId.add(acc.id);
        }
        AccountProcessor.countContacts(acntId);
        Test.stopTest();
        
    }
}