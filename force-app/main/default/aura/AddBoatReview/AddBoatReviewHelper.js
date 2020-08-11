({
	onInit : function(component, event,helper) {
		component.find("service").getNewRecord(
            "BoatReview__c", 
            null,      
            false,     
            $A.getCallback(function() {
                var recds = component.get("v.boatReview");
                var eror = component.get("v.recordError");
                var boats=component.get("v.boat");
                if(eror || (recds === null)) {
                console.log("Error initializing record template: " + error);   
                }
                else {
                    component.set("v.boatReview.Boat__c",boats.Id);
                    var test=component.get("v.boatReview");
                }
            })
        );
	}
})