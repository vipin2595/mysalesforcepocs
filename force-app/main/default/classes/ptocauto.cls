public class ptocauto {
    
    Public static void updatefield(list<Contact> Apps)
    {
        List<Contact> lstConUpdate = new List<Contact>();
         set<Id> item = new set<Id>();
        for(Contact a : Apps)
        {
             item.add(a.AccountId);
        } 
    
    List<Contact> lstContact = [select id,AccountId,Account.Name,Account.Phone,Account.Fax from Contact where AccountId in: item];
    for(Contact con: lstContact){
        con.LastName = con.Account.Name;
        con.Phone = con.Account.Phone; 
        con.Fax = con.Account.Fax; 
       
        lstConUpdate.add(con);
    }
    if(lstConUpdate.size() > 0){
        update lstConUpdate;
        } 
    }
    
}