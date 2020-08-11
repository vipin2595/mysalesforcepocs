@istest
public class TestVerifyDate {
    @istest static void verifydatedata(){
        VerifyDate.CheckDates(date.valueof('2019-01-01'),date.valueof('2019-02-01'));
    }
    @istest static void verifydatedata1(){
        VerifyDate.CheckDates(date.valueof('2019-01-01'),date.valueof('2019-01-30'));
    }
    
}