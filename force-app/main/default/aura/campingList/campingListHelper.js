({
	createItem : function(component, Camping) {
        var action = component.get("c.saveItem");
        action.setParams({
            "Camping": Camping
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var Item = component.get("v.Items");
                Item.push(response.getReturnValue());
                component.set("v.Items", Item);
               
            }
        });
        $A.enqueueAction(action);
	}
})