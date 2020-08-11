({
		 packItem: function(component, event, helper) { 
        let item = component.get("v.item");
        item.Packed__c = true;
        component.set("v.item", item);
        component.set("v.disabled", true)
		let button = component.find('disablebuttonid');
    	button.set('v.disabled',true);
	}
})