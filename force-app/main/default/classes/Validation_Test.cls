@isTest
public class Validation_Test {
    @isTest static void VendorCountOnSingleInsert_Test() {
        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;

        insert newVendor;

        Vendor_Event__c updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(1, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');
    }

    @isTest static void VendorCountOnBulkInsert_Test() {
        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        List<Vendor__c> bulkVendors = new List<Vendor__c>();

        for (Integer i = 0; i < 120; i++) {
            Vendor__c newVendor = new Vendor__c();
            newVendor.Vendor_Event__c = newEvent.Id;
            bulkVendors.add(newVendor);
        }

        Test.startTest();
        insert bulkVendors;
        Test.stopTest();

        Vendor_Event__c updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(120, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');
    }

    @isTest static void VendorCountOnSingleDelete_Test() {
        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;

        insert newVendor;

        Vendor_Event__c updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(1, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');

        delete newVendor;

        updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(0, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');
    }


    @isTest static void VendorCountOnSingleInsertWithoutVendorEvent_Test() {
        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();

        insert newVendor;

        Vendor_Event__c updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(0, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');
    }


    @isTest static void VendorCountOnSingleUpdate_Test() {
        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;

        insert newVendor;

        Vendor_Event__c updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(1, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');

        Vendor_Event__c newEvent2 = new Vendor_Event__c();
        newEvent2.Name = 'Event 12';

        insert newEvent2;
        newVendor.Vendor_Event__c = newEvent2.Id;

        update newVendor;

        updatedEvent = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(0, updatedEvent.Vendor_Count__c, 'Count of vendors is not as expected');

        Vendor_Event__c updatedEvent2 = 
            [select Vendor_Count__c
             from Vendor_Event__c
             where Id = :newEvent2.Id limit 1];

        System.assertEquals(1, updatedEvent2.Vendor_Count__c, 'Count of vendors is not as expected');
    }


    @isTest static void EventDatesOnSingleInsert_Test() {
        Datetime firstOpen = Datetime.now();
        Datetime lastClose = Datetime.now().addHours(8);


        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;
        newVendor.Vendor_Start_Date__c = firstOpen;
        newVendor.Vendor_End_Date__c = lastClose;

        insert newVendor;

        Vendor_Event__c updatedEvent = 
            [select Start_Date__c, End_Date__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(firstOpen, updatedEvent.Start_Date__c, 'Event Start is incorrect');
        System.assertEquals(lastClose, updatedEvent.End_Date__c, 'Event End is incorrect');
    }

    @isTest static void EventDatesOnMultiInsert_Test() {
        Datetime firstOpen = Datetime.now();
        Datetime lastClose = Datetime.now().addHours(8);


        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;
        newVendor.Vendor_Start_Date__c = firstOpen;
        newVendor.Vendor_End_Date__c = lastClose.addMinutes(-10);

        insert newVendor;

        Vendor__c newVendor2 = new Vendor__c();
        newVendor2.Vendor_Event__c = newEvent.Id;
        newVendor2.Vendor_Start_Date__c = firstOpen.addMinutes(10);
        newVendor2.Vendor_End_Date__c = lastClose;

        insert newVendor2;

        Vendor_Event__c updatedEvent = 
            [select Start_Date__c, End_Date__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(firstOpen, updatedEvent.Start_Date__c, 'Event Start is incorrect');
        System.assertEquals(lastClose, updatedEvent.End_Date__c, 'Event End is incorrect');
    }

    @isTest static void EventDatesOnMultiInsertMissingDates_Test() {
        Datetime firstOpen = Datetime.now();
        Datetime lastClose = Datetime.now().addHours(8);


        Vendor_Event__c newEvent = new Vendor_Event__c();
        newEvent.Name = 'Event 1';

        insert newEvent;

        Vendor__c newVendor = new Vendor__c();
        newVendor.Vendor_Event__c = newEvent.Id;
        newVendor.Vendor_Start_Date__c = firstOpen;

        insert newVendor;

        Vendor__c newVendor2 = new Vendor__c();
        newVendor2.Vendor_Event__c = newEvent.Id;
        newVendor2.Vendor_End_Date__c = lastClose;

        insert newVendor2;

        Vendor_Event__c updatedEvent = 
            [select Start_Date__c, End_Date__c
             from Vendor_Event__c
             where Id = :newEvent.Id limit 1];

        System.assertEquals(firstOpen, updatedEvent.Start_Date__c, 'Event Start is incorrect');
        System.assertEquals(lastClose, updatedEvent.End_Date__c, 'Event End is incorrect');
    }
}