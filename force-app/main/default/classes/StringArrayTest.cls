public class StringArrayTest {
    public static list<string> generateStringArray (Integer Incominginteger ){
        list<String> generateStringlist = new list<String>();
        for(integer i=0;i<=Incominginteger;i++){
            string addstrngnumber = 'test'+' '+ String.valueOf(i);
            generateStringlist.add(addstrngnumber);
        }
   System.debug(generateStringlist);
        return generateStringlist ;
        
    }

}