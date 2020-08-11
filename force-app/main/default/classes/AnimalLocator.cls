public class AnimalLocator {
    
    public static string getAnimalNameById(Integer input){
        string animals = '';
        Http http = new Http();
        httprequest htpreq = new httprequest();
        htpreq.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/'+input);
        htpreq.setMethod('GET');
        Httpresponse resp = http.send(htpreq);
        if(resp.getStatusCode() == 200){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
           
            // Cast the values in the 'animals' key as a list
           Map<string,object> animalss = (map<string,object>) results.get('animal');
            
                animals = string.valueof(animalss.get('name'));
                System.debug(animals);
          
        }
        system.debug(animals);
        return animals;
    }

}