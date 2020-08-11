({
    clickCreateItem : function(component, event, helper) {
        var validCamping = component.find('itemform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if(validCamping){
            // Create the new expense
            var newcampingitme = component.get("v.newItem");
            helper.createItem(component, newcampingitme);
             /*var camping = component.get("v.items");
            var item = JSON.parse(JSON.stringify(newcampingitme));
            
            camping.push(item);
            component.set("v.items", camping);*/
             
        }
    },
    // Load Camping list from Salesforce
    doInit: function(component, event, helper) {
        // Create the action
        var action = component.get("c.getItems");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.items", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },
     handleAddItem: function(component, event, helper) {
        var newItem = event.getParam("item");
        var action = component.get("c.saveItem");
        action.setParams({"item": newItem});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var items = component.get("v.items");
                items.push(item);
                component.set("v.items",items);
            }
        });
        $A.enqueueAction(action);
        
    },
})
/*
({
    clickCreateItem : function(component, event, helper) {
        var validCamping = component.find('itemform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if(validCamping){
            var newCampingItem = component.get("v.newItem");
            //helper.createCamping(component,newCampingItem);
            var campings = component.get("v.items");
            var item = JSON.parse(JSON.stringify(newCampingItem));
            
            campings.push(item);
            
            component.set("v.items",campings);
            component.set("v.newItem",{ 'sobjectType': 'Camping_Item__c','Name': '','Quantity__c': 0,
                                       'Price__c': 0,'Packed__c': false });
        }
    }
})
*/