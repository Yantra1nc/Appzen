({
    handleInit : function(component, event, helper) {
        setTimeout(function(){ 
            $A.get('e.force:refreshView').fire();
        }, 1);
    },
    refreshView: function(component, event) {
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },
})