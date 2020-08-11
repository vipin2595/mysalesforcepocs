public with sharing class OpportunityLineItemHandler implements Itrigger{
    
    public void bulkBefore(){

    } 
    public void bulkAfter(){

    } 
    public void beforeInsert(List<SObject> newlstObj){
    
    } 
    public void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){

    } 
    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
        
    } 
    public void afterInsert(List<SObject> newlstObj, Map<Id,SObject> newMapObj){

    } 
    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        insertAuditHistory((Map<Id, OpportunityLineItem>)oldMapObj, (Map<Id, OpportunityLineItem>)newMapObj);
    } 
    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
    
    }
    public void andFinally(){

    }

    public static void insertAuditHistory(Map<Id,OpportunityLineItem> oldMapObj, Map<Id,OpportunityLineItem> newMapObj){

        List<Audit_History__c> insertAuditHistory = new List<Audit_History__c>();
        for(OpportunityLineItem ol : newMapObj.values()){
            if(ol.UnitPrice != oldMapObj.get(ol.Id).UnitPrice){
                Audit_History__c auditHist = new Audit_History__c();
                auditHist.Record_Id__c = ol.Id;
                auditHist.Field_Name__c = 'Sales Price';
                auditHist.Object_Name__c = 'Opportunity Product';
                auditHist.Old_Value__c = String.valueOf(oldMapObj.get(ol.Id).UnitPrice);
                auditHist.New_Value__c = String.valueOf(ol.UnitPrice);
                insertAuditHistory.add(auditHist);
            }
        }

        insert insertAuditHistory;
    }
}