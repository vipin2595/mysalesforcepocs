public class VendorTriggerHandler implements ITrigger {
    
    /*
    Use Case:
    BACKGROUND:
    A vendor event organizer wants to track planned vendor events, and vendors who will be showcasing their wares at each event.

    The organizer wants to be able to look at a event entry and know how many vendors are attending that event, 
    and when the first vendor will open their booth, and when the last vendor will close their booth.

    There are two objects:

    Vendor Event

    Vendor

    The Vendor object has a lookup to the Vendor Event object.

    REQUIREMENTS:

    Create a trigger to save the number of vendors linked to a vendor event to the Vendor Count field on the Vendor Event object.
    Also, of the vendors that are linked to a fair, save the earliest Vendor Open date/time on the Vendor Object to the Event Start date/time on the Vender Event Object.
    Finally, of the vendors that are linked to a fair, save the latest Vendor Closed date/time on the Vendor Object to the Event End date/time on the Vendor Event Object.

    Don't forget to code for edge cases, and write tests for your code.

    EXPERT TIP:

    ﻿A validation test class called Validation_Test has been provided to help you meet these requirements. 
    Your code will be checked against this test and reported to the test administrator.

    Note: Don't change this test to circumvent requirements. We'll know about it, and you'll fail anyway, 
    as we undo any changes to this test when we validate your code.
    */
    public static void bulkBefore(){
        
    } 
    public static void bulkAfter(){
        
    } 
    public static void andFinally(){
        
    } 
    /**
     * beforeInsert
     */
    public static void beforeInsert(List<SObject> newlstObj){
        
    } 
    /**
     * beforeUpdate
     */
    public static void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        
    }

    /**
     * beforeDelete
     */
    public static void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
        
    }

    /**
     * afterInsert
     */
    public static void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj){
        updateVendorCount((Map<Id, Vendor__c>)newMapObj);
    }

    /**
     * afterUpdate
     */
    public static void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        updateVendorCount((Map<Id, Vendor__c>)newMapObj);
    }

    /**
     * afterDelete
     */
    public static void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
        updateVendorCount((Map<Id, Vendor__c>)oldMapObj);
    }
    
    /**
     * @Description : 
     * @Param       :
     * @Return      :
     */
    private static void updateVendorCount(Map<Id, Vendor__c> newMapObj){
        
        Set<Id> vendorEventSet = new Set<Id>();
        
        for(Vendor__c vendor : newMapObj.values()){
            vendorEventSet.add(vendor.Vendor_Event__c);
        }
        
        // Map<Id, Vendor_Event__c> vendorEventsMap = new Map<Id, Vendor_Event__c>();
        // for(Vendor__c vc :[SELECT Id, Vendor_Event__c, Vendor_Start_Date__c, Vendor_End_Date__c, Vendor_Event__r.Start_Date__c, Vendor_Event__r.End_Date__c FROM Vendor__c WHERE Vendor_Event__c IN :vendorEventSet]){
        //     if(vendorEventsMap.containsKey(vc.Vendor_Event__c)){
        //         Vendor_Event__c ve = vendorEventsMap.get(vc.Vendor_Event__c);
        //         ve.Vendor_Count__c += 1; 
        //         if(ve.Start_Date__c == null){
        //             ve.Start_Date__c = vc.Vendor_Event__r.Start_Date__c;
        //         }
        //         else if(ve.Start_Date__c > vc.Vendor_Start_Date__c){
        //            ve.Start_Date__c =  vc.Vendor_Start_Date__c;
        //         }
        //         if(ve.End_Date__c == null){
        //             ve.End_Date__c =  vc.Vendor_Event__r.End_Date__c;
        //         }
        //         else if(ve.End_Date__c < vc.Vendor_End_Date__c ){
        //             ve.End_Date__c = vc.Vendor_End_Date__c;
        //         }
        //         vendorEventsMap.put(vc.Vendor_Event__c, ve);
        //     }
        //     else{
        //         vendorEventsMap.put(vc.Vendor_Event__c, new Vendor_Event__c (
        //                                                     Id = vc.Vendor_Event__c ,
        //                                                     Vendor_Count__c = 1, 
        //                                                     Start_Date__c = vc.Vendor_Start_Date__c, 
        //                                                     End_Date__c = vc.Vendor_End_Date__c));
        //     }
            
        // }
        // update vendorEventsMap.values();
        List<Vendor_Event__c> vEUpdate = new List<Vendor_Event__c>();
        if(vendorEventSet.isEmpty()){
            return;
        }
        for(Vendor_Event__c ve : [SELECT Id, Vendor_Count__c, Start_Date__c, End_Date__c,
                                    (SELECT Id, Vendor_Start_Date__c, Vendor_End_Date__c  FROM Vendors__r) 
                                FROM Vendor_Event__c WHERE Id IN :vendorEventSet]){
            //Integer Count = 0;
            ve.Vendor_Count__c = ve.Vendors__r.size() != null ? ve.Vendors__r.size() : 0;
            //system.debug(count);
            DateTime earliestStartDate = DateTime.newInstanceGMT(1998, 1, 29, 2, 2, 3);
            DateTime latestEndDate = DateTime.newInstanceGMT(1998, 1, 29, 2, 2, 3);
            for(Vendor__c vc : ve.Vendors__r){
           
                system.debug(vc.Vendor_Start_Date__c);
                system.debug(vc.Vendor_End_Date__c);
                if(vc.Vendor_Start_Date__c != null){
                    earliestStartDate = vc.Vendor_Start_Date__c;
                    ve.Start_Date__c =  earliestStartDate.getTime() <= vc.Vendor_Start_Date__c.getTime() ? vc.Vendor_Start_Date__c : earliestStartDate;
                }
                if(vc.Vendor_End_Date__c !=null){
                    latestEndDate = vc.Vendor_End_Date__c;
                    ve.End_Date__c = vc.Vendor_End_Date__c.getTime() >= latestEndDate.getTime() ? vc.Vendor_End_Date__c : latestEndDate;
                } 
            }
            vEUpdate.add(ve);
        }
        update vEUpdate;
        
    }

}