/* 
refernce
for(SObject lc : newlstObj){
            for(Integer count = 0; count < (Decimal)lc.get('Number_of_Months__c'); count++){
                Installment_Payment_Plan__c iPp = new Installment_Payment_Plan__c();
                iPp.Loan_Name__c = lc.Id;
                iPp.Monthly_Payment__c = (Decimal)lc.get('Loan_Amount__c')/(Decimal)lc.get('Number_of_Months__c');
                iPp.Payment_Date__c = system.today().addMonths(count);
                ippList.add(iPp);
            }
        }
*/

public with sharing class loanTriggerHandler implements Itrigger{
    public loanTriggerHandler() {

    }
    public void bulkBefore(){

    } 
    public void bulkAfter(){

    } 
    public void beforeInsert(List<SObject> newlstObj){
        System.debug('beforeInsert');
        System.debug('newlstObj'+newlstObj);
    } 
    public void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        System.debug('beforeUpdate');
        System.debug('newlstObj'+newlstObj);
        System.debug('oldMapObj'+oldMapObj);
    } 
    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
        deleteRelatedInstallementPaymentPlan(oldMapObj.keySet());
    } 
    public void afterInsert(List<SObject> newlstObj, Map<Id,SObject> newMapObj){
        System.debug('afterInsert');
        System.debug('newlstObj'+newlstObj);
        System.debug('oldMapObj'+newMapObj);
        installmentPaymentPlancalclate((List<Loan__c>)newlstObj);
    } 
    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        //sendEmailNotification((Map<Id,Loan__C>) newMapObj, (List<Loan__C>)newlstObj);
    } 
    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
    
    }
    public void andFinally(){

    }
    public static void deleteRelatedInstallementPaymentPlan(Set<Id> loanId){
        List<Installment_Payment_Plan__c> deleteInstallementPaymentPlanList = [SELECT Id,Loan_Name__c FROM Installment_Payment_Plan__c WHERE Loan_Name__c = :loanId];
        delete deleteInstallementPaymentPlanList;
    }
    public static void installmentPaymentPlancalclate(List<Loan__c> loanlst){
        List<Installment_Payment_Plan__c> ippList = new List<Installment_Payment_Plan__c>();
        for(Loan__c lc : loanlst){
            Integer principalAmount = 0;
            for(Integer count = 0; count < lc.Number_of_Months__c; count++){
                Installment_Payment_Plan__c iPp = new Installment_Payment_Plan__c();
                iPp.Loan_Name__c = lc.Id;
                iPp.Monthly_Payment__c = lc.Loan_Amount__c * lc.APR__c/100 * (1 + lc.APR__c/100)*lc.Number_of_Months__c/((1 + lc.APR__c/100)*lc.Number_of_Months__c - count);
                iPp.Payment_Date__c = system.today().addMonths(count);
                ippList.add(iPp);
                //P= Loan amount, r= interest rate, n=tenure in number of months.
            }
        }
        insert ippList;
    }
    public static void sendEmailNotification(Map<Id, Loan__C> triggerOldMap, List<Loan__C> triggerNewList){
        system.debug('sendEmailNotification Start ***');
        Map<String, Map<String,String>> oldval = New Map<String, Map<String, String>>();

           EmailTemplate emailTemp = [SELECT 
                                        subject, HTMLValue 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName = :'Opportunity_fields_update_Email_HTML'];
   
           List<Loan__C> opportunityList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Bank_Institution_Name__c, APR__c, Number_of_Months__c, Loan_Amount__c
                                                from Loan__c  
                                                       WHERE Id IN :triggerNewList];
   
       //Master list to hold the emails 
           List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
           List<String> sendTo = new List<String>();
           //sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory).Split(','));
           for(Loan__c oppLineItem : opportunityList){
   
               String htmlBodyReplace = emailTemp.HTMLValue;
               String htmlBody = ' ';  
               sendTo.add(oppLineItem.OwnerId);
               htmlBody = '<h3>Hello ,</h3><br></br><p>Bellow are the list of fields was updated '+ oppLineItem.Name + 'at' + oppLineItem.SystemModstamp + '</p><br></br><h2>Opportunity Product Fields</h2>';
               htmlBody += '<table><tr><th>Field</th><th>Old Value</th><th>New Value</th></tr>';
               //if(triggerOldMap.get(oppLineItem.Id).Quantity != oppLineItem.Quantity){
                   htmlBody += '<tr><td> Amount </td><td>' +oppLineItem.Name + '</td><td>' + oppLineItem.Name + '</td></tr>';
               //}
               //if(triggerOldMap.get(oppLineItem.Id).SHIFT_MEDIA__Price__c != oppLineItem.SHIFT_MEDIA__Price__c){}
               htmlBody += '<tr><td> Amount </td><td>' + oppLineItem.Name + '</td><td>' + oppLineItem.Name + '</td></tr>';
               htmlBody += '</table>';
               htmlBodyReplace = htmlBodyReplace.replace('listfields__T',htmlBody);
               Messaging.SingleEmailMessage singlemessage = generateHtmlSingleEmailMessage(sendTo, htmlBodyReplace, emailTemp.Id);
               system.debug('singlemessage***'+singlemessage);
               mails.add(singlemessage);
               }
               system.debug('mails***'+mails);
               Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
           if (results[0].success) {
                       System.debug('The email was sent successfully.');
                   } else{
                       System.debug('The email failed to send: ' + results[0].errors[0].message);
                   }
                   system.debug('sendEmailNotification End ***');
                //    List<Opportunity> triggerNewopp;
                //    List<Opportunity> opportunityList1 = [SELECT Id FROM Opportunity
                //           WHERE Id IN :triggerNewopp];
               }
       //Sprint-5
   
       public static Messaging.SingleEmailMessage generateHtmlSingleEmailMessage(List<String> sendToList, String htmlBody, Id templateId) {
   
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setToAddresses(sendToList);
           
           //mail.setTargetObjectId(targetObjectId);
           mail.setSaveAsActivity(false);
           //mail.setWhatId(opp.Id);
           mail.setTemplateId(templateId); 
           mail.setHtmlBody(htmlBody);
           //mail.setPlainTextBody(plainBody);
           //mail.setSubject(emailTemp.Subject);
           //mail.setSenderDisplayName('Test Email');
           //mail.setHtmlBody(emailTemp.HtmlValue);
           //mail.setPlainTextBody(emailTemp.body);
           return mail;
       }
       //Sprint-5
}


