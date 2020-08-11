@RestResource(urlMapping='/Garnish/*')
global with sharing class GarnishInfo {
    @HttpGet
    global static list<Contact> getContactByGarnish() {
        RestRequest request = RestContext.request;
        // grab the cheese from the end of the URL
        System.debug(request);
        String garnish = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        System.debug('Garnish is '+garnish);
        Id id=[SELECT Id FROM Garnish__c where Name=: garnish].Id;
        list<junc__c> relatedContacts = [SELECT Contact__c FROM junc__c WHERE Garnish__c =: Id];
        list<Id> contactIds= new list<Id>();
        for(junc__c j:relatedContacts){
            contactIds.add(j.Contact__c);
        }
        list<Contact> cons=[SELECT Id,Name,AccountId FROM Contact Where Id IN: contactIds];
        return cons;
    }
}