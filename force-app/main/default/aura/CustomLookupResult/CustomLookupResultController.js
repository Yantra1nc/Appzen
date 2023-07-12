({
    selectRecord : function(component, event, helper){  
        // get the selected record from list  
        var getSelectRecord = component.get("v.oRecord");
        var compEvent = component.getEvent("Selectedaccount");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"selectAccount" : getSelectRecord });
        compEvent.fire();
    }
})