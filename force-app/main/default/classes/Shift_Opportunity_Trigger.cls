/*
 *  Name          : Shift_Opportunity_Trigger
 *  Author        : Shift CRM
 *  Reference    : DSPolitical - Enhancements - DEL-00034219
 *  Description   : Trigger that creates a map of all Opportunities with a new stage of 'Closed Lost'
 *           and then calls Shift_Opportunity_TriggerHandler to delete any related Production
 *           records.
 * 
 *  Maintenance History:
 *  Date (yyyy/mm/dd) -- Name  -------------  Version ---- Remarks
 *  2016/01/08           Matthew Anderson     0.1          Initial
 */
trigger Shift_Opportunity_Trigger on Opportunity (before update, after insert) {
    
    Shift_Opportunity_TriggerHandler opportunityTriggerHandler = new Shift_Opportunity_TriggerHandler();
    Map<Id, Opportunity> lostOpportunities = new Map<Id, Opportunity>();

    if (trigger.isBefore) {
        if (trigger.isUpdate) { 
          for (Opportunity opp: trigger.new) {
          // Create a list of Opportunities with a new stage of 'Closed Lost'
                if (opp.StageName != trigger.OldMap.get(opp.Id).StageName && opp.StageName == 'Closed Lost') {
                  lostOpportunities.put(opp.Id, opp);
                }
            }  
        }
    }
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            
        }
        if(trigger.isUpdate){
            opportunityTriggerHandler.afterUpdate(trigger.oldMap, trigger.new);
        }
    }
    
    // Do work on the selected Opportunities
    opportunityTriggerHandler.deleteProductionRecords(lostOpportunities);
}
