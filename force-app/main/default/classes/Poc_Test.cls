@isTest
public without sharing class Poc_Test {
    
    static testMethod void Poc_Test1() {

        Account acc = new Account();
        List<Account> accList = new List<Account>();
        for(integer i=0 ;  i<60000; i++){
            acc.Name = 'test'+i;
            accList.add(acc);
        }
        insert accList;

        List<Account> accountList = [SELECT Name FROM Account WHERE Id IN :accList];

    }
}
