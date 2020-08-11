/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (before update, after update,before delete, after delete,after undelete) {
    
    if (Trigger.new != null) {
    OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    }
}