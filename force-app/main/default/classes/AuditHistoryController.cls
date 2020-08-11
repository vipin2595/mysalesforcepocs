public with sharing class AuditHistoryController {
    
    @AuraEnabled
    public static List<Audit_History__c> getAuditHistoryRecords(String oppProductId){

        List<Audit_History__c> auditList = [SELECT 
                                                Id, Field_Name__c, New_Value__c,Old_value__c, 
                                                CreatedDate, owner.name
                                            FROM Audit_History__c
                                            WHERE Record_Id__c = :oppProductId 
                                            ORDER BY CreatedDate DESC];
        if(auditList.isEmpty()){
            throw new AuraHandledException('No Audit History Found');
        }

        return auditList;
    }
}