@istest
public class WarehouseSyncScheduleTest {
    @istest static void WarehouseSyncSch(){
        String CRON_EXP = '0 0 1 1/1 * ? *';
        WarehouseSyncSchedule reminder = new WarehouseSyncSchedule();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String jobID = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, reminder);
        
    }
    
    
}