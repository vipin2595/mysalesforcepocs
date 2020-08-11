trigger VendorTrigger on Vendor__c (after insert, after delete, after update) {
	TriggerFactory.execute(new VendorTriggerHandler()); 
}