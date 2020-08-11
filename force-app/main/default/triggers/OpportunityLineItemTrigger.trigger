trigger OpportunityLineItemTrigger on OpportunityLineItem (after update) {
    TriggerFactory.execute(new OpportunityLineItemHandler());  
}