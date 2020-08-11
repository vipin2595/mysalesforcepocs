trigger MaintenanceRequest on Case (before update, after update) {
    // call MaintenanceRequestHelper.updateWorkOrders  
    //MaintenanceRequestHelper.updateWorkOrders helper = new MaintenanceRequestHelper.updateWorkOrders();
    if(Trigger.isAfter && Trigger.isUpdate) 
        
    { 
        system.debug('Trigger.newmap'+Trigger.newmap.size()); 
        MaintenanceRequestHelper.updateWorkOrders(Trigger.newmap);
        system.debug('*****Before Update******'); 
        
    } 
}