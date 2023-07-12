({
	searchhelper : function(component,event,getInputkeyWord) {
		 var recordId = component.get('v.recordId');
        var action = component.get("c.queryAccounts");
         action.setParams({
            'recordId' : recordId,
            'searchKeyWord': getInputkeyWord
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var result = response.getReturnValue()
            console.log('result',result);
             component.set('v.accounts',result)
            }
        });
        $A.enqueueAction(action); 
	},
    
})