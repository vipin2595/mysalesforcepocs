public class Acoounttriggerhelper {
    
    public static void beforeinsert(list<Account> triggernewinsert){
       AccountAddress(triggernewinsert); 
    }
	public static void beforeupdate(list<Account> triggerupdate){
        AccountAddress(triggerupdate);
    }
    private static void AccountAddress(list<Account> triggernew)
    {
        for (account acc : triggernew){
                if(acc.Match_Billing_Address__c == True){
                    acc.ShippingPostalCode=acc.BillingPostalCode;
                }
                //else{}
            }
    }
}