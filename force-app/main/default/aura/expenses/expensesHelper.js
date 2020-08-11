({
    /*createExpense: function(component, expense) {
        var theExpenses = component.get("v.expenses");
        
        // Copy the expense to a new object
        // THIS IS A DISGUSTING, TEMPORARY HACK
        var newExpense = JSON.parse(JSON.stringify(expense));
        console.log("Expenses before 'create': " + JSON.stringify(theExpenses));
        theExpenses.push(newExpense);
        component.set("v.expenses", theExpenses);
        console.log("Expenses after 'create': " + JSON.stringify(theExpenses));
    }*/
    createExpense: function(component, expense) {
        var action = component.get("c.saveExpense");
        action.setParams({
            "expense": expense
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var expenses = component.get("v.expenses");
                expenses.push(response.getReturnValue());
                component.set("v.expenses", expenses);
               
            }
        });
        $A.enqueueAction(action);
        var newcampingitme = component.get("v.newExpense");
         component.set("v.newExpense",{ 'sobjectType': 'Expense__c',
                             'Name': '',
                             'Amount__c': 0,
                             'Client__c': '',
                             'Date__c': '',
                             'Reimbursed__c': false });
    },
        updateExpense: function(component, expense) {
        var action = component.get("c.saveExpense");
        action.setParams({
            "expense": expense
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                // do nothing!
            }
        });
        $A.enqueueAction(action);
    },
})