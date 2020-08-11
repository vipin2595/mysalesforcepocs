public with sharing class ContactRelatedListController {

    public List<contact> contacts{get;set;} 
    public Account accounts {get;set;} 
    public Account acc {get;set;} 
    public Boolean Rating{get;set;}

    //Constructor 
    public ContactRelatedListController(ApexPages.StandardController controller) { 
        system.debug(Rating);
        Rating = true;
        system.debug(Rating);
        apexpages.Message ms=new apexpages.Message(apexpages.Severity.error,'You are not allowed to access this PAGE');
        apexpages.addmessage(ms);
        acc = (account)controller.getRecord();      
        accounts = [SELECT id FROM account WHERE id=: acc.id LIMIT 1]; 
        contacts = [SELECT id, Name, mobilephone, email FROM contact WHERE accountid = :accounts.id ORDER BY Name];     

} 

    //This method is to create a new contact while clicking on the Add contact button 
    public pageReference newContact(){  
        pageReference pageRef = new pageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/003/e?&retURL=' + accounts.id);  
        return pageRef; 
    } 

    //This method is to edit the existing contact record while clicking the Edit link 

    public pageReference editContact(){  
        String contactId = Apexpages.currentpage().getParameters().get('contactId');  
        pageReference pageRef = new pageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + contactId + '/e?retURL=' + accounts.id);  
        return pageRef;  
    }    

 //This method is to delete the contact record while clicking the Del link 

    public pageReference deleteContact(){  
        String contactId = Apexpages.currentpage().getParameters().get('contactId');  
        contact contactList = [SELECT Id FROM contact WHERE id = : contactId LIMIT 1]; 
        delete contactList; 
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); 
        PageReference redirectPage = new PageReference(baseUrl+'/'+accounts.id); 
        return redirectPage;  
    }   
}