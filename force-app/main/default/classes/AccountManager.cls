//@RestResource(UrlMapping='/Accounts/*/contacts')
/*Global with sharing class AccountManager {
    @HttpGet 
    Global static Account[] getAccount(){
        RestRequest request = RestContext.request;
        // grab the AccountId from the end of the URL
        String AccountId =  request.requestURI.substringBetween('Accounts/','/contacts');
        Account[] result =  [SELECT id,name,(select id,name from contacts) 
                        FROM Account
                        WHERE Id = :AccountId];
        return result;
    }
    
}
*/
@RestResource(urlMapping='/Accounts/*/contacts')
global with Sharing class AccountManager {
   @httpGet
    global static Account getAccount(){
        
         RestRequest request=RestContext.request;
        System.debug('aaaaaaaaaaaatest'+request.requestURI);
         String accid= request.requestURI.substringBetween('Accounts/','/contacts');
        System.debug('aaaaaaaaaaaatest '+request.requestURI.substringBetween('Accounts/','/contacts'));
         Account acc=[Select id,name,(Select id, name from Contacts) from account where id=:accid];
        return acc;
    }
}