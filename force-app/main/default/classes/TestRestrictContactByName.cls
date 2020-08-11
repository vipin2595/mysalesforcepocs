@istest
public class TestRestrictContactByName {
    @istest static void TestRestrictContactByName1(){
        Account ac = new Account(Name='Test Acc1');
        insert ac;
        contact cn = new contact(LastName='lastname',AccountId=ac.id);
        insert cn;
        contact cn1 = new contact(LastName='INVALIDNAME',AccountId=ac.id);
        insert cn1;
    }

}