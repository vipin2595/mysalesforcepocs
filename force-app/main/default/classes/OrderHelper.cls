public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    @TestVisible 
    private static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<Id, Product2> prodMap = new Map<Id, Product2>();
        Set<Id> prodIds = new Set<Id>();
        
       
        List<OrderItem> items = [SELECT Id, Product2Id, Quantity FROM OrderItem WHERE OrderId In :activatedOrderIds];
        
       
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