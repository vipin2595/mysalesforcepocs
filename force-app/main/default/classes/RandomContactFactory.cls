public class RandomContactFactory {
    public static list<Contact> generateRandomContacts (Integer noofcontgente, string lastnameparam){
        list<Contact> con = new list<Contact>();
        for(integer i=1;i<=noofcontgente;i++){
            contact cn = new contact();
            cn.FirstName='test'+(i);
            cn.lastname=lastnameparam;
            con.add(cn);
        }
        return con;
        
    }

}