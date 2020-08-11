system.debug(UserInfo.getOrganizationId()+'-'+Userinfo.getSessionId().substring(15));


delete [select id from Hospital__c ];


EmailMissionSpecialist.sendMail('121fa05147@gmail.com', 'Trailhead Tutorial', '123 body');

StringArrayTest.generateStringArray(5);

pharmamaxinventorybyaccount.pharmamaxinventorybyacc();
EmailManager em = new EmailManager();
em.sendMail('121fa05147@gmail.com', 'Flight Path Change', 
   'Mission Control 123: Your flight path has been changed to avoid collision '
   + 'with asteroid 2014 QO441.');

Contact thisContact = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com');
insert thisContact;

List<List<sObject>> searchList = [FIND 'Mission Control' IN ALL FIELDS 
                                  RETURNING Contact(FirstName, LastName,
                                  Phone, Email, Description)];
Contact[] searchContacts = (Contact[])searchList[0];
System.debug('Found the following contacts:');
for (Contact c : searchContacts) {
   System.debug(c.LastName + ', ' + c.FirstName);
}
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
request.setMethod('GET');
HttpResponse response = http.send(request);
// If the request is successful, parse the JSON response.
if (response.getStatusCode() == 200) {
    // Deserialize the JSON string into collections of primitive data types.
    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    // Cast the values in the 'animals' key as a list
    List<Object> animals = (List<Object>) results.get('animals');
    System.debug('Received the following animals:');
    for (Object animal: animals) {
        System.debug(animal);
    }
}
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
request.setMethod('POST');
request.setHeader('Content-Type', 'application/json;charset=UTF-8');
// Set the body as a JSON object
request.setBody('{"name":"mighty moose"}');
HttpResponse response = http.send(request);
// Parse the JSON response
if (response.getStatusCode() != 201) {
    System.debug('The status code returned was not expected: ' +
        response.getStatusCode() + ' ' + response.getStatus());
} else {
    System.debug(response.getBody());
}
AnimalLocator.getAnimalNameById(1);

calculatorServices.CalculatorImplPort calculator = new  calculatorServices.CalculatorImplPort();
Double x = 1.0;
Double y = 2.0;
Double result = calculator.doAdd(x,y);
System.debug(result);

AccountProcessor.getAccountsid();

WarehouseCalloutService.runWarehouseEquipmentSync();

WarehouseSyncSchedule reminder = new WarehouseSyncSchedule();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String sch = '0 0 1 1/1 * ? *';
String jobID = System.schedule('WarehouseSyncSchedule', sch, reminder);


String q = 'SELECT First_Name__c, Last_Name__c, Email__c FROM Speaker__c WHERE Email__c != null';
SendReminderEmail batch = new SendReminderEmail(q, 'Final Reminder', 'The conference starts next Monday');
Database.executeBatch(batch);

    decimal x=0;
Decimal myDecimal = 1+(2.40/100);
    for(integer i=1; i<=3 ; i++){
        
        Decimal powDec = (((1+(2.40/100)).pow(i))*405370).setScale(0, RoundingMode.HALF_UP);
        system.debug('i'+powDec); 
        x = powDec + x;
        system.debug('i'+x); 
    }
system.debug('i'+x/3); 


String[] test = new string();
test.add('set');

system.debug('Output'+test);


test.calculation(3,5);
List<String> str = new List<String>();
//str.addAll(String.valueOf(System.label.Opportunity_update_email_directory).split(','));
str.add('abc \n');
str.add('def \n');
str.replace('[^a-zA-Z0-9\\s+]', '');
System.debug(str);


List<Opportunity> opportunityList = [SELECT 
                                                Name, Owner.Email, LastModifiedBy.name,
                                                Amount, SystemModstamp
                                            FROM Opportunity 
                                            LIMIT 1];
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
       List<String> bodyconstruct = new List<String>();
        //sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory).split(','));
        for(Opportunity opp : opportunityList){

            ///
            String body = '';
            //if(opp.Amount != triggerOldMap.get(opp.Id).Amount){
                bodyconstruct.add('Amount field was updated from'+ opp.Name+' to '+opp.Name);
            //}
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Step 2: Set list of people who should get the email
            sendTo.add(opp.Owner.email);
            mail.setToAddresses(sendTo);
            
            // Step 3: Set who the email is sent from
            mail.setSenderDisplayName('Opportuniy field update');
            // Step 4. Set email contents - you can use variables!
            mail.setSubject('OPPORTUNITY FIELD WAS UPDATED');
            //'Your case:<b> ' + case.Id +' </b>has been created.<p>'+'To view your case <a href=https://na1.salesforce.com/'+case.Id+'>click here.</a>'
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

/////////////////////////////////////////


EmailTemplate emailTemp = [SELECT 
    Id, subject, Body 
    FROM EmailTemplate 
    WHERE DeveloperName=:'Opportunity_fields_update_Email_text'];
    List<Opportunity> opportunityList = [SELECT 
                    Name, Owner.Email, LastModifiedBy.name,
                    Amount, SystemModstamp
                FROM Opportunity limit 1 ];
    // Step 0: Create a master list to hold the emails we'll send
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    List<String> sendTo = new List<String>();
	//sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory.Split(',')));
for(Opportunity opp : opportunityList){

        ///
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        sendTo.add(opp.Owner.email);
        mail.setToAddresses(sendTo);
        String body = '';
        body = 'Amount field was updated by'+ opp.LastModifiedBy.name +'from to '+ opp.Amount +' at '+ opp.SystemModstamp +'';
        //mail.setSubject(emailTemp.Subject);
        mail.setSenderDisplayName('Test Email');
        //mail.setHtmlBody(emailTemp.HtmlValue);
        //mail.setPlainTextBody(emailTemp.body);
        String plainBody = emailTemp.Body;
        plainBody = plainBody.replace('listfields__T',body);
        mail.setTargetObjectId(opp.owner.id);
        mail.setSaveAsActivity(false);
        //mail.setWhatId(opp.Id);
        mail.setTemplateId(emailTemp.id); // #throwing error here
        mail.setPlainTextBody(plainBody);
        mails.add(mail);
        ////
    }

    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }

///////////////////////////////////////
/*HTML */
EmailTemplate emailTemp = [SELECT 
    Id, subject, HTMLValue 
    FROM EmailTemplate 
    WHERE DeveloperName=:'Opportunity_fields_update_Email_HTML'];
    List<Opportunity> opportunityList = [SELECT 
                    Name, Owner.Email, LastModifiedBy.name,
                    Amount, SystemModstamp
                FROM Opportunity LIMIT 1 ];
    // Step 0: Create a master list to hold the emails we'll send
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    List<String> sendTo = new List<String>();
	//sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory.Split(',')));
for(Opportunity opp : opportunityList){

        ///
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        sendTo.add(opp.Owner.email);
        mail.setToAddresses(sendTo);
        String htmlBody = '';
        String body = '';
        body = 'Amount field was updated by'+ opp.LastModifiedBy.name +'from to '+ opp.Amount +' at '+ opp.SystemModstamp +'';
        //mail.setSubject(emailTemp.Subject);
        mail.setSenderDisplayName('Test Email');
        //mail.setHtmlBody(emailTemp.HtmlValue);
        //mail.setPlainTextBody(emailTemp.body);
        htmlBody = '<tr><td> Amount </td><td>' + opp.name + '</td><td>' + opp.Owner.Email + '</td></tr>';
        htmlBody += '<tr><td> Amount </td><td>' + opp.Id + '</td><td>' + opp.Owner.Email + '</td></tr>';
        String plainBody = emailTemp.HTMLValue;
        plainBody = plainBody.replace('listfields__T',htmlBody);
        plainBody = plainBody.replace('Opportunity__T',opp.name);
        mail.setTargetObjectId(opp.owner.id);
        mail.setSaveAsActivity(false);
        //mail.setWhatId(opp.Id);
        mail.setTemplateId(emailTemp.id); // #throwing error here
        //mail.setPlainTextBody(plainBody);
        mail.setHtmlBody(plainBody);
        mails.add(mail);
        ////
    }

    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
//////////////////////////////


trigger OpportunityBeforeUpdate  on Opportunity (before update, after update) {
    
    if (trigger.isBefore) {
        if (trigger.isUpdate) { 
            for(sObject optyObj : trigger.newMap.values()){
                Opportunity opty = (Opportunity )optyObj ;
                Opportunity oldOpty = (Opportunity )trigger.oldMap.get(opty.Id);
                if(opty != oldOpty){
                    string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opty.recordtypeid).getname();
                    List<Currency__c> curr = [Select Id,Exchange_Rate__c,Buffer_Percentage__c,Currency_Name__c from Currency__c where Opportunity_Country__c = :opty.Country__c];
                    if(curr.size() > 0 && string.valueof(curr.get(0).Exchange_Rate__c) !=null && recordtypename == 'International'){
        //system.debug('Name--'+curr.get(0).Exchange_Rate__c+opty.StageName+opty.Conversion_Rate__c);
                        opty.Currency_Name__c = curr.get(0).Currency_Name__c;
                        if((opty.StageName == 'Closed Won' || opty.StageName == 'Closed Lost') &&  String.valueof(opty.Conversion_Rate__c) == null){
                            opty.Conversion_Rate__c = curr.get(0).Exchange_Rate__c;
                        }
                        if(recordtypename == 'International' && string.valueof(opty.Conversion_Rate__c) != null){
                            opty.Amount_in_USD__c = opty.Amount * opty.Conversion_Rate__c;
                        }
                        else{
                            opty.Amount_in_USD__c = opty.Amount * curr.get(0).Exchange_Rate__c;
                        }
                    }
                    if(curr.size() > 0 && string.valueof(curr.get(0).Buffer_Percentage__c ) !=null && recordtypename == 'International'){
                        opty.Currency_Name__c = curr.get(0).Currency_Name__c;
                        if((opty.StageName == 'Closed Won' || opty.StageName == 'Closed Lost') &&  String.valueof(opty.Conversion_Rate__c) == null){
                            opty.Buffer_Percentage__c = curr.get(0).Buffer_Percentage__c;
                        }
                        if(recordtypename == 'International' && string.valueof(opty.Buffer_Percentage__c) != null){
                            opty.Buffer_Amount__c = (opty.Amount * opty.Buffer_Percentage__c)/100;
                        }
                        else{
                            opty.Buffer_Amount__c = (opty.Amount * curr.get(0).Buffer_Percentage__c)/100;
                        }
                    }
                }
            }
        }
    }
    // Sprint-5
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            
        }
        if(trigger.isUpdate){
            opportunityTriggerHandler.afterUpdate(trigger.oldMap, trigger.new);
        }
    }
   //Sprint-5
}


////////

///////////////////////////////////////
/*HTML */
EmailTemplate emailTemp = [SELECT 
    Id, subject, HTMLValue 
    FROM EmailTemplate 
    WHERE DeveloperName=:'Opportunity_fields_update_Email_HTML'];
    List<Opportunity> opportunityList = [SELECT 
                    Name, Owner.Email, LastModifiedBy.name,
                    Amount, SystemModstamp
                FROM Opportunity LIMIT 1 ];
    // Step 0: Create a master list to hold the emails we'll send
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    List<String> sendTo = new List<String>();
	//sendTo.addAll(String.valueOf(System.label.Opportunity_update_email_directory.Split(',')));
for(Opportunity opp : opportunityList){

        ///
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        sendTo.add(opp.Owner.email);
        mail.setToAddresses(sendTo);
        String htmlBody = '';
        String body = '';
        body = 'Amount field was updated by'+ opp.LastModifiedBy.name +'from to '+ opp.Amount +' at '+ opp.SystemModstamp +'';
        //mail.setSubject(emailTemp.Subject);
        mail.setSenderDisplayName('Test Email');
        //mail.setHtmlBody(emailTemp.HtmlValue);
        //mail.setPlainTextBody(emailTemp.body);
        htmlBody = '<h3>Hello ,</h3><br></br><p>Bellow are the list of fields was updated </p><br></br><h2>Opportunity Product Fields</h2>';
            htmlBody += '<table><tr><th>Field</th><th>Old Value</th><th>New Value</th></tr>';
            htmlBody += '<tr><td> Amount </td><td>' + opp.name + '</td><td>' + opp.Owner.Email + '</td></tr>';
            htmlBody += '<tr><td> Amount </td><td>' + opp.Id + '</td><td>' + opp.Owner.Email + '</td></tr>';
            htmlBody += '</table>';
        String plainBody = emailTemp.HTMLValue;
        plainBody = plainBody.replace('listfields__T',htmlBody);
        plainBody = plainBody.replace('Opportunity__T',opp.name);
        //mail.setTargetObjectId(opp.owner.id);
        mail.setSaveAsActivity(false);
        //mail.setWhatId(opp.Id);
        mail.setTemplateId(emailTemp.id); // #throwing error here
        //mail.setPlainTextBody(plainBody);
        mail.setHtmlBody(plainBody);
        mails.add(mail);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else{
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
    }

///////////////////////////////

Map<String, Map<String,Map<String,String>>> oldval = New Map<String, Map<String, Map<String,String>>>();

Map<String,Map<String,String>> submap = new Map<String,Map<String,String>>();
Map<string,string> InMap = new Map<string,string>();
Map<string,string> subsubMap = new Map<string,string>();


subMap.put('cde','def');
oldval.put('Abc',new Map<String,String>());
oldval.get('Abc').putAll(subMap);

system.debug(oldval.get('Abc').values());

Map<Id,Map<String,Sobject>> oppproductOld = new Map<Id,Map<String,Sobject>>();
Map<Id,Map<String,Sobject>> oppproductNew = new Map<Id,Map<String,Sobject>>();


//////////////////////////////////

Map<Id, List<OpportunityLineItem>> oppProductOldMap = new Map<Id, List<OpportunityLineItem>>();

for(OpportunityLineItem oppLineItem : [Select Id,Name from OpportunityLineItem limit 10 ]){
    if(oppProdOldMap.containsKey(oppLineItem.opportunityId)) {
        List<OpportunityLineItem> optyOldLine = oppProdOldMap.get(oppLineItem.opportunityId);
        optyOldLine.add(oppLineItem);
        oppProdOldMap.put(oppLineItem.opportunityId, optyOldLine);
        List<OpportunityLineItem> optyNewLine = oppProdNewMap.get(oppLineItem.opportunityId);
        optyNewLine.add(triggerNewMap.get(oppLineItem.Product2Id));
        oppProdNewMap.put(triggerNewMap.get(oppLineItem.Product2Id).opportunityId, optyNewLine);
    }
    else {
        oppProdOldMap.put(oppLineItem.opportunityId, new List<OpportunityLineItem> { oppLineItem });
        oppProdNewMap.put(triggerNewMap.get(oppLineItem.Product2Id).opportunityId, new List<OpportunityLineItem> { triggerNewMap.get(oppLineItem.Product2Id) });
    }
//sendEmailNotification(triggerOldMap, triggerNewList);
}


//////////////////////////////////////

public static void CreateSobject(Schema.SObjectType sobj){
    Schema.SObjectType expected = Schema.Account.getSObjectType();

}






