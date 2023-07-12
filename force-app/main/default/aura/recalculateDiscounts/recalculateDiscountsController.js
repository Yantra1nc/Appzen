({
    doInit : function(component, event, helper) 
    {
        component.set("v.showSpinner",true);
        var action = component.get("c.FlowMethod");
        action.setParams({ 'opportunityId' : component.get("v.recordId") })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message:'Given Discount Applied Successfully...!',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
                component.set("v.showSpinner",true);
            }   
            else if (state === "INCOMPLETE") {
                // do something
                component.set("v.showSpinner",true);
            }
                else if (state === "ERROR") {
                    //  alert('In error');
                    var errors = response.getError();                      
                    component.set("v.showErrors",true);
                    component.set("v.errorMessage",errors[0].message);
                    console.log('error:'+errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        
                        message:errors[0].message,
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:closeQuickAction').fire();         
                    
                    component.set("v.showSpinner",true);
                    
                }
        });
        $A.enqueueAction(action);
    }
})