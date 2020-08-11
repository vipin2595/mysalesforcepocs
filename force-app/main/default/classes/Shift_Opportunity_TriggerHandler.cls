/*
 *  Name          : Shift_Opportunity_TriggerHandler
 *  Author        : Shift CRM
 *  Reference    : DSPolitical - Enhancements - DEL-00034219
 *  Description   : deleteProductionRecords method deletes all Production Records 
 *           related to all Opportunities within a Map of Opportunities provided
 *           as an argument.
 * 
 *  Maintenance History:
 *  Date (yyyy/mm/dd) -- Name  -------------  Version ---- Remarks
 *  2016/01/08           Matthew Anderson     0.1          Initial
 */
public class Shift_Opportunity_TriggerHandler {
    public Shift_Opportunity_TriggerHandler() {}
    
    public void deleteProductionRecords(Map<Id, Opportunity> lostOpportunities)
    {
        // Get a list of all Production records related to the lost opportunities
        List<SHIFT_MEDIA__Production__c> productionsToDelete = [SELECT Id
                                                           FROM SHIFT_MEDIA__Production__c
                                                           WHERE SHIFT_MEDIA__Opportunity__c IN :lostOpportunities.keySet()];
        
        // Delete Productions + Error Handling
        if (productionsToDelete != null && !productionsToDelete.isEmpty()) {
            List<Database.DeleteResult> deleteResults = Database.delete(productionsToDelete, false);
            Integer i = 0;
            for (Database.DeleteResult deleteResult : deleteResults) {
                if (!deleteResult.isSuccess()) {
                    for(Database.Error err : deleteResult.getErrors()) {
                        lostOpportunities.get(productionsToDelete[i].SHIFT_MEDIA__Opportunity__c).addError(err.getMessage());
                    }
                }
                i++;
            }
        }
    }
    public void afterInsert(Map<Id, Opportunity> triggerOldMap, List<Opportunity> triggerNewList){

    }
    public void afterUpdate(Map<Id, Opportunity> triggerOldMap, List<Opportunity> triggerNewList){
        sendEmailNotification(triggerOldMap, triggerNewList);
    }
    public static void sendEmailNotification(Map<Id, Opportunity> triggerOldMap, List<Opportunity> triggerNewList){
        // Added query to get all the opportunity and the related fields value.
        EmailTemplate emailTemp = [SELECT 
                                Id, subject, body 
                            FROM EmailTemplate 
                            WHERE DeveloperName=:'Opportunity_fields_update_Email_text'];
        List<Opportunity> opportunityList = [SELECT 
                                                Name, Owner.Email, LastModifiedBy.name,
                                                Amount, SystemModstamp
                                            FROM Opportunity 
                                            WHERE Id IN :triggerNewList];
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<String> bodyconstruct = new List<String>();
        sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory).split(','));
        for(Opportunity opp : opportunityList){

            ///
            String body = '';
            if(opp.Amount != triggerOldMap.get(opp.Id).Amount){
                bodyconstruct.add('Amount field was updated from '+ opp.Name+' to '+opp.Name);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Step 2: Set list of people who should get the email
            sendTo.add(opp.Owner.email);
            mail.setToAddresses(sendTo);
            
            // Step 3: Set who the email is sent from
            mail.setSenderDisplayName('Opportuniy field update');
            // Step 4. Set email contents - you can use variables!
            mail.setSubject('OPPORTUNITY FIELD WAS UPDATED');
            body += 'Dear ,';
            body += '<br><br>What you need to know:';
            body += '<br> Opportunity '+opp.Name +' was by '+ opp.LastModifiedBy.name +' at '+ opp.SystemModstamp +'.';
            body += '<br>Fields updated on opportunity<br>';
            body += '•       '+bodyconstruct+'<br>';
            mail.setHtmlBody(body);
            
            // Step 5. Add your email to the master list
            mails.add(mail);
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);

        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}