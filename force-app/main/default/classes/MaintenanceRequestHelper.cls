/*
 * Automatically create a Routine Maintenance request every time a maintenance request of type Repair or Routine Maintenance is updated to Closed. 
 */
public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(Map<id,Case> NewCaseMap){
        // update workorders
        map<id,list<Work_Part__c>> WorkPartMap = new map<id,list<Work_Part__c>>();
        List<Case> CaseList = new List<Case>();
        for(case CS : [select id,
                       CaseNumber,
                       ContactId,
                       AccountId,
                       Status, 
                       Reason, 
                       Origin, 
                       Subject, 
                       Priority, 
                       Description,
                       PotentialLiability__c, 
                       Date_Due__c, Date_Reported__c, 
                       Equipment__c, Vehicle__c, 
                       maintenance_request__c, 
                       Routine_Maintenance__c,
                       Type,
                       Type__c,
                       (select id,Equipment__c,Quantity__c  from Work_Parts__r )  
                       from case where id =:NewCaseMap.keyset()] ){
                           
                           if(CS.Type=='Repair' || CS.Type=='Routine Maintenance'){
                               system.debug('CS.Status'+CS.Status);
                               if(CS.Status=='Closed'){
                                   system.debug('Enter Loop --->');
                                   case cse = CS.clone(false, true);
                                   cse.maintenance_request__c='Repair';
                                   cse.Routine_Maintenance__c='Open';
                                   cse.Type='Routine Maintenance'; 
                                   cse.Date_Due__c= cs.Work_Parts__r.size()<0 ? System.today():System.today()+1;  
                                   cse.Date_Reported__c= System.today();
                                   cse.parentid=cs.id;
                                   cse.Status='New';
                                   CaseList.add(cse);
                                   WorkPartMap.put(cse.parentid,CS.Work_Parts__r.deepclone(false,false,false));
                               }
                               
                           }
                       }
       
        if(CaseList!=null && CaseList.size()>0){
            insert CaseList;
        }
        List<Work_Part__c> records = new List<Work_Part__c>();
        for(Case CE :CaseList){
          
            for(Work_Part__c WC: WorkPartMap.get(CE.parentid)){
                WC.maintenance_request__c= CE.id;
            }
        }
        for (List<Work_Part__c> grouping : WorkPartMap.values()){
            records.addAll(grouping); 
        }
        
        if(records!=null && records.size()>0){
            insert records;
        }
        
    } 
    //Get the least Maintenance_Cycle__c date from child records.
    /*public static Integer DueDate(id caseid){
        Integer duedatecalc;
        for(aggregateResult  WC :[Select min(Equipment__r.Maintenance_Cycle__c) Maintenance_Cycle from Work_Part__c where Maintenance_Request__c =:caseid] ){
            duedatecalc=  wc.get('Maintenance_Cycle')!=null?((Decimal) wc.get('Maintenance_Cycle')).intvalue():0;
        }
        return duedatecalc;
    }*/
    
}