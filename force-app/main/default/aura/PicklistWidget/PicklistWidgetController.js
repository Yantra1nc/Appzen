({
    doInit: function(component, event, helper) {     
        window.addEventListener("click", function(){
            //var cmpTarget = component.find('myPicklist');
            //console.log(cmpTarget);           
        	//$A.util.removeClass(cmpTarget, 'slds-is-open');
            var divElement = document.querySelector('.slds-dropdown-trigger_click.slds-is-open');
            if(divElement!=null)
            {
                console.log(divElement.classList);           
                divElement.classList.remove("slds-is-open");
            }
        });
    },
    showOptions : function(component, event, helper) {
        event.stopPropagation();
		var cmpTarget = component.find('myPicklist');
		$A.util.toggleClass(cmpTarget, "slds-is-open"); 
	},
    selectValue : function(component, event, helper) {
        event.stopPropagation();
        helper.selectValue(component, event, helper);
    },    
    /* Method to search Accounts on keyup */
    search : function(component, event, helper) {
        helper.search(component, event, helper);
    },    
    /* Method to close dropdown */
    closeDropdown : function (component, event, helper) {
        //alert('closing..');
        event.stopPropagation();
        var cmpTarget = component.find('myPicklist');
        $A.util.removeClass(cmpTarget, 'slds-is-open');
    }
})