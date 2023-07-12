({
    doInit : function(component, event, helper) {
        var getInputkeyWord = ' ';
        helper.searchhelper(component,event,getInputkeyWord);
    },
    onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = ' ';
        helper.searchhelper(component,event,getInputkeyWord);
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log(getInputkeyWord);
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchhelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.accounts", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    handleComponentEvent:function(component,event,helper){
        component.set("v.isSelected",true);
        
        var selectedAccountGetFromEvent = event.getParam("selectAccount");
        component.set("v.selectedAccounts",selectedAccountGetFromEvent);
        console.log('selectedAccounts '+JSON.stringify(selectedAccountGetFromEvent));
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');   
       // helper.updateopportunity(component,event,selectedAccountGetFromEvent);
    },
    clear :function(component,event,helper,selectedAccountGetFromEvent){
        component.set('v.isTrue',"false");
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.accList", null );
        component.set("v.Accountval", {} );   
    },
    updateopportunity : function(component,event,helper) {
        var recordId = component.get('v.recordId');
        var selectedAccount = component.get("v.selectedAccounts");
        console.log(selectedAccount.Id);
        var action = component.get("c.updateOpportunity");
        action.setParams({
            'selectedAccount' : selectedAccount.Id,
            'recordId'       : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();           
                location.reload();
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type":"error",
                            "message": errors[0].message
                        });
                        toastEvent.fire();                      }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });
        $A.enqueueAction(action); 
    }
})