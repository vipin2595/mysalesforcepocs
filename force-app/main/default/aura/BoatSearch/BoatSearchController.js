({
    onFormSubmit: function(component, event, helper){
        var formData = event.getParam("formData");
        var boatTypeId = formData.boatTypeId;
        
        var BSRcmp = component.find("BSRcmp");
    var auraMethodResult = BSRcmp.search(boatTypeId);
    },
    doSearch:function(component, event, helper) {
    },
    search: function(component, event, helper){
        var params = event.getParam('arguments');
        helper.onSearch(component,event);
        return "search complete.";
    }

})