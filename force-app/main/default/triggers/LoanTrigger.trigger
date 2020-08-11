trigger LoanTrigger on Loan__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {    
    TriggerFactory.execute(new loanTriggerHandler());  
}