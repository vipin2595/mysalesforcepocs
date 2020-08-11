@RestResource(urlMapping='/ContactInfo')
global with sharing class ContactInfo{
  @HttpPost
    global static Id createContact(String id, String accountId, String email, String firstName, String lastName,String[] garnish) {
        Contact c=new Contact();
        String owner=[SELECT OwnerId FROM Account WHERE Id=:accountId].OwnerId;
        Date today = Date.today();
        list<Garnish__c> garnishIDs=[SELECT Id FROM Garnish__c WHERE Name IN: garnish];
        System.debug('Garnish Ids '+garnishIDs);
        list<junc__c> j=new list<junc__c>();
        
        //If Contact Id is not supplied
        if(id==''){
            //create New
            c.AccountId=accountId;
            c.FirstName=firstName;
            c.LastName=lastName;
            c.Email=email;
            insert c;
            for(Garnish__c gId:garnishIds){
                junc__c ju= new junc__c(contact__c=c.Id,garnish__c=gId.Id);
                j.add(ju);
            }
            insert j;
            
            Task t=new Task(OwnerId=owner,ActivityDate=today + 2,Status='In Progress',Subject='Get in Touch',WhatId=accountId,WhoId=c.Id);
            insert t;
        }
        //If Contact id is present
        else{
            //Search and check for old and update
            if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)){
                c=[SELECT Id,AccountId,FirstName,LastName FROM Contact WHERE ID =:Id];
                c.AccountId=accountId;
                c.Email=email;
                c.FirstName=firstName;
                c.LastName=lastName;
                update c;
                for(Garnish__c gId:garnishIds){
                    junc__c ju= new junc__c(contact__c=c.Id,garnish__c=gId.Id);
                    j.add(ju);
                }
                insert j;
                
                Task t=new Task(OwnerId=owner,ActivityDate=today + 2,Status='In Progress',Subject='Get in Touch',WhatId=accountId,WhoId=c.Id);
                insert t;
            }
            else{
                    //bad Id
            }
        }

        return c.Id;
    }   
}