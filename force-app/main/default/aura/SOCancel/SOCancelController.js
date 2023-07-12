({
    "handleConfirmDialog":function(cmp, event, helper) {
        cmp.set('v.showConfirmDialog', true);
    },
    "handleConfirmDialogNo":function(cmp, event, helper) {
        console.log('No');
        cmp.set('v.showConfirmDialog', false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        $A.get('e.force:refreshView').fire();
        dismissActionPanel.fire(); 
    },
    "handleConfirmDialogYes":function(cmp, event, helper) {
        console.log('Yes');
        cmp.set('v.showConfirmDialog', false);
        console.log('Yes confirm');
        var action = cmp.get("c.soCancelMethod");
      	var test = cmp.get("v.recordId");
        
        action.setParams({ recordId : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getReturnValue();
            console.log(response.getReturnValue());
            console.log(state);
            if (state == "Success") {
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                $A.get('e.force:refreshView').fire();
                dismissActionPanel.fire();    
              
            }else if(state == "Error"){
                console.log(response.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Invoices already generated in Uniware,hence cannot cancel the order."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})