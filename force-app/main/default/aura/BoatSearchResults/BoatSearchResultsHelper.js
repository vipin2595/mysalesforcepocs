({
 onSearch : function(component) {
        console.log('here1'+component.get("v.boatTypeId1"));
     	var x=component.get("v.boatTypeId1")
        var action1 = component.get("c.getBoats");
        if(x=='All Types'){
            x='';
        }
		 	var action1 = component.get("c.getBoats");
        	action.setParams({
          	"boatTypeId":x
        	});
        	 debugger
    		action1.setCallback(this, function(response) {
               
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.boats", response.getReturnValue());
                }
                else {
                    console.log("Failed with state1: " + state);
                }
        	});
    		$A.enqueueAction(action1);
	}
})