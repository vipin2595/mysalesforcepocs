@istest
public class TaskUtiltest {
    @istest static void testtaskprority(){
        TaskUtil.getTaskPriority('Japan');
    }
    @istest static void testtaskprority1(){
        TaskUtil.getTaskPriority('CA');
    }
    @istest static void testtaskprority2(){
        TaskUtil.getTaskPriority('NY');
    }
}