trigger AccountAddressTrigger on Account (before insert,before update) {
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        if (Trigger.isBefore) {
            // Process before insert
            Acoounttriggerhelper.beforeinsert(Trigger.new);
             Acoounttriggerhelper.beforeupdate(Trigger.new);
        }
    }
    
    

        else if (Trigger.isAfter) {
            // Process after insert
        }        
    
    else if (Trigger.isDelete) {
        // Process after delete
    }
    
}