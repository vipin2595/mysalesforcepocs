/*public class WarehouseSyncSchedule {
  // implement scheduled code here
}*/
global class WarehouseSyncSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // awesome code here
        WarehouseCalloutService.runWarehouseEquipmentSync();
    }
}