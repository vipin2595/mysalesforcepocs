/*
 * This class uses the @future annotation and makes a callout to an external service used for warehouse inventory management. 
 * This service receives updated values in the external system and update the related records in Salesforce
 * 
*/

public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request); 
        if(response.getStatusCode() == 200){
             List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('results'+results);
             List<Product2> EquipmentUpdList = new List<Product2>();
            for(Object Obj: results){
                Map<String, Object> EquipmentMap = (Map<String, Object>)Obj;
                Product2 Equip = new Product2();
                Equip.Name = (String)EquipmentMap.get('name');
                Equip.Cost__c = (Integer)EquipmentMap.get('cost');
                Equip.Current_Inventory__c = (Integer)EquipmentMap.get('quantity');
                Equip.Maintenance_Cycle__c = (Integer)EquipmentMap.get('maintenanceperiod');
                Equip.Replacement_Part__c = (Boolean)EquipmentMap.get('replacement');
                Equip.Lifespan_Months__c = (Integer)EquipmentMap.get('lifespan');
                Equip.Warehouse_SKU__c = (String)EquipmentMap.get('sku');
                Equip.ProductCode = (String)EquipmentMap.get('_id');
                EquipmentUpdList.add(Equip);
            }
            if(EquipmentUpdList.size()>0 && EquipmentUpdList!=null){
                upsert EquipmentUpdList Warehouse_SKU__c;
            }
        }
    }

}