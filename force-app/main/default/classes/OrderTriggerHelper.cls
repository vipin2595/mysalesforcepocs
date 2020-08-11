public class OrderTriggerHelper {
    public static void afterupd(List<Order> nwLi, List<Order> olLi){
        Set<Id> activeOrdIds = new Set<Id>();
        
        for (Integer i = 0; i < nwLi.size(); i++) {
            if(nwLi[i].Status == Constants.ACTIVATED_ORDER_STATUS && olLi[i].Status == Constants.DRAFT_ORDER_STATUS) {
                activeOrdIds.add(nwLi[i].Id);
            }
        }
        
        OrderItem(activeOrdIds);
    }
    
    public static void OrderItem(Set<Id> actorderids){
        
        
        Map<Id, Product2> prodMap = new Map<Id, Product2>();
        Set<Id> prodIds = new Set<Id>();
        
       
        List<OrderItem> items = [SELECT Id, Product2Id, Quantity FROM OrderItem WHERE OrderId In :actorderids];
        
       
        for(OrderItem oi : items) {
            prodIds.add(oi.Product2Id);
        }
        
        prodMap = new Map<Id, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN:prodIds]);
        
        AggregateResult[] aggrtResults  = [SELECT Product2Id, SUM(Quantity) aggregatedQuantity FROM OrderItem WHERE Product2Id In :prodMap.keySet() GROUP BY Product2Id];
        
        for (AggregateResult arr : aggrtResults)  {
            prodMap.get((String)arr.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(arr.get('aggregatedQuantity'));
        }
        
        if(prodMap != null && prodMap.size() > 0) {
            update prodMap.values();
        }
    }
    
    
}