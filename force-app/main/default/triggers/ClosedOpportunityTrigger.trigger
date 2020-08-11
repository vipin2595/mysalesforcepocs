trigger ClosedOpportunityTrigger on Opportunity (before insert,before update) {
    
    if (Trigger.isInsert ) {
        if (Trigger.isBefore) {
            // Process before insert
            //Acoounttriggerhelper.beforeinsert(Trigger.new);
            //Acoounttriggerhelper.beforeupdate(Trigger.new);
            list<Task> bulktaskinsert = new  list<Task>();
            for(Opportunity opp : trigger.new){
                if(opp.StageName =='Closed Won'){
                    String userId = UserInfo.getUserId();
                    Task t = new Task();
                    t.OwnerId = userId;
                    t.Subject = 'Follow Up Test Task';
                    t.Status = 'Open';
                    t.Priority = 'Normal';
                    t.WhatId = opp.Id;
                    bulktaskinsert.add(t); 
                } 
            }
            if(bulktaskinsert.size()>0 && bulktaskinsert!=null){
                insert bulktaskinsert; 
            }
            
            
        }
    }
    else if(Trigger.isUpdate){
        if (Trigger.isBefore){
            Map<id,Opportunity> relatedopp = new Map<id,Opportunity>([SELECT id,(SELECT id FROM Tasks) FROM Opportunity where id in : trigger.new]);
            list<Task> bulktaskupdate = new  list<Task>();
            for(Opportunity opp : trigger.new){
                if (relatedopp.get(opp.Id).Tasks.size() == 0){
                    if(opp.StageName =='Closed Won' ){
                        String userId = UserInfo.getUserId();
                        Task t = new Task();
                        t.OwnerId = userId;
                        t.Subject = 'Follow Up Test Task';
                        t.Status = 'Open';
                        t.Priority = 'Normal';
                        t.WhatId = opp.Id;
                        bulktaskupdate.add(t); 
                    } 
                }
                
            }
            if(bulktaskupdate.size()>0 && bulktaskupdate!=null){
                insert bulktaskupdate; 
            }
        }
    }
    
    
    
    else if (Trigger.isAfter) {
        // Process after insert
    }        
    
    else if (Trigger.isDelete) {
        // Process after delete
    }
    
}