public with sharing class BoatSearchResults {
    @AuraEnabled
    public static List<BoatType__c> getBoattypes() {
        return [select id, Name from BoatType__c];
    }
    @AuraEnabled
    public static List<Boat__c> getBoats(String boatTypeId) {
        if(string.isEmpty(boatTypeId)){
            return [select id, Name, Contact__c, BoatType__c, Description__c, Geolocation__Latitude__s, 
                    Geolocation__Longitude__s, Geolocation__c, Length__c, Picture__c, Price__c, Year_Built__c 
                    from Boat__c ];  
        }
        else{
            return [select id, Name, Contact__c, BoatType__c, Description__c, Geolocation__Latitude__s, 
                    Geolocation__Longitude__s, Geolocation__c, Length__c, Picture__c, Price__c, Year_Built__c 
                    from Boat__c where id =:boatTypeId];
        }
    }
    
}