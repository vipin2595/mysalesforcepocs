public class AccountProcessor {
    Public static void getAccountsid(){
        list<id> acntId = new list<id>();
        list<account> accountid = [select id from account];
        for(account acc : accountid){
            acntId.add(acc.id);
        }
        countContacts(acntId);
    }
    @future
    public static void countContacts(list<id> acntId ){
        Map<id, Decimal> AccountcontactMap = new Map<Id, Decimal>();
        Map<id, Decimal> AccountcontactMap2 = new Map<Id, Decimal>();
        for(Contact cc : [select id,Account.Number_of_Contacts__c,accountid from contact where accountid =:acntId]){
            if(AccountcontactMap.containsKey(cc.accountid)) {
                AccountcontactMap.put(cc.accountid,AccountcontactMap.get(cc.accountid) + 1);
            } else {
                AccountcontactMap.put(cc.accountid,1 );
                AccountcontactMap2.put(cc.accountid,cc.Account.Number_of_Contacts__c!=null ? cc.Account.Number_of_Contacts__c:0);
            }
            
        }
        list<Account> NoOfcontactupdate = new list<Account>();
        for(id acc: AccountcontactMap.keyset()){
            
            Account acnt = new account();
            system.debug(AccountcontactMap.get(acc));
            system.debug(AccountcontactMap2.get(acc));
            if(AccountcontactMap.get(acc)>AccountcontactMap2.get(acc)){
                
                acnt.Number_of_Contacts__c = AccountcontactMap.get(acc);
                acnt.Id= acc;
                NoOfcontactupdate.add(acnt); 
            }
        }
        if(NoOfcontactupdate!=null && NoOfcontactupdate.size()>0){
            update NoOfcontactupdate;
        }
        system.debug(AccountcontactMap);
        
    }
}
/*
Backup
public class AccountProcessor {
Public static void getAccountsid(){
list<id> acntId = new list<id>();
list<account> accountid = [select id from account];
for(account acc : accountid){
acntId.add(acc.id);
}
countContacts(acntId);
}
@future
public static void countContacts(list<id> acntId ){
Map<id, Decimal> AccountcontactMap = new Map<Id, Decimal>();
for(Contact cc : [select id,Account.Number_of_Contacts__c,accountid from contact where accountid =:acntId]){
if(AccountcontactMap.containsKey(cc.accountid)) {
AccountcontactMap.put(cc.accountid,AccountcontactMap.get(cc.accountid) + 1);
} else {
AccountcontactMap.put(cc.accountid, cc.Account.Number_of_Contacts__c!=null ? cc.Account.Number_of_Contacts__c:1 );
}

}
list<Account> NoOfcontactupdate = new list<Account>();
for(id acc: AccountcontactMap.keyset()){

Account acnt = new account();
acnt.Number_of_Contacts__c = AccountcontactMap.get(acc);
acnt.Id= acc;
NoOfcontactupdate.add(acnt);
}
if(NoOfcontactupdate!=null && NoOfcontactupdate.size()>0){
update NoOfcontactupdate;
}
system.debug(AccountcontactMap);

}
}
*/