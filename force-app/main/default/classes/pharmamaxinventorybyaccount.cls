public class pharmamaxinventorybyaccount {
    public static void pharmamaxinventorybyacc(){
        map<id,List<integer>> pharmamap = new map<id,List<integer>>();
        list<decimal> pharmalist = new list<decimal>();
        for(Pharma_Product__c pharma :[select id,Account_id__c,Inventory__c from Pharma_Product__c]){
            if(pharmamap.containsKey(pharma.Account_id__c) ) {
                                  List<integer> inventory = pharmamap.get(pharma.Account_id__c);
                inventory.add(integer.valueof(pharma.Inventory__c));

                pharmamap.put(pharma.Account_id__c, inventory);  
                if(integer.valueOf(pharmamap.get(pharma.Account_id__c))>integer.valueOf(pharmamap.get(pharma.Account_id__c))){

                pharmamap.put(pharma.Account_id__c, inventory);  
                }   
            } else {
                pharmamap.put(pharma.Account_id__c, new List<integer> { integer.valueof(pharma.Inventory__c) });
            }
            
        }
        system.debug(pharmamap);
    }
}