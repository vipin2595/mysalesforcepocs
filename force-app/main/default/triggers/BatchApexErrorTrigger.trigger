trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {  
   BatchLeadConvertErrors__c[] insertErrorList = new BatchLeadConvertErrors__c[]{};  
   for(BatchApexErrorEvent error : trigger.new)  
   {  
     BatchLeadConvertErrors__c errorLogs = new BatchLeadConvertErrors__c();  
     errorLogs.AsyncApexJobId__c = error.AsyncApexJobId;  
     errorLogs.Records__c = error.JobScope;  
     errorLogs.StackTrace__c = error.StackTrace;  
     insertErrorList.add(errorLogs);  
   }  
   insert insertErrorList;   
 }