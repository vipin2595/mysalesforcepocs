@istest
public class DailyLeadProcessorTest {
    // Seconds,Minutes,Hours,Day_of_month,Month Day_of_week,optional_year 
    public static String CRON_EXP = '10 0 0 1 2 ?';
    @testsetup static void leadinert(){
        
        List<Lead> leadList =  new List<Lead>();
        for(integer i=0;i<200;i++){
            leadList.add(new Lead(LastName='Scheduler Test'+i,Company = 'Test Company'+i));
        }
        Insert leadList;
    }
    @istest
    Static void leadscheduleTest(){
        test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new DailyLeadProcessor());
        test.stopTest();
    }

}