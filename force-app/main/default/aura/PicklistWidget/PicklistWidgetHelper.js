({
    showHide : function(component, event, helper){
        var cmpTarget = component.find('myPicklist');
        $A.util.toggleClass(cmpTarget, 'slds-is-open');
    },
    selectValue : function(component, event, helper) {
        var multi = component.get("v.multiselect");
        var source = event.currentTarget;
        var selected = component.get("v.selectedOptions");
        var selectedLabel;
        var opts = [];
        var selectedValues = component.get("v.selectedValues");
        var remainingOpts = component.get("v.optionsBackup");
        if(!multi){
            var index = selected.indexOf(source.id);
            if(index > -1){
                selected = [];
            }
            else {
                selected = [];
                selected.push(source.id);
                selectedLabel = source.title;
            }
        }
        else {
            var index = selected.indexOf(source.id);
            if(index == -1){
                selected.push(source.id);
                selectedValues.push({id:source.id, title:source.title});
            }
            else {
                selected.splice(index, 1);
                selectedValues.splice(index, 1);
            }
            selectedLabel = source.title;
        }
        component.set("v.selectedOptions",selected);
        if(selectedValues.length == 1)
        {
            component.set("v.selectedLabel",selectedValues[0].title);
        }
        else
        {
            component.set("v.selectedLabel",selectedLabel);
        }
        
        var cmpTarget = component.find('myPicklist');
        if(!multi){
            $A.util.removeClass(cmpTarget, "slds-is-open");
        }
    },
    /* Method to search Accounts on keyup */
    search : function(component, event, helper) {
        var tempOptn = component.get("v.optionsBackup");
        var tempConList = component.get("v.options");
        if(tempOptn.length < 1){
            component.set("v.optionsBackup", tempConList);
        }
        var searchstring = component.get("v.searchString");
        var filteredConList= [];
        var conList = [];
        if(searchstring && tempConList) {
            for(var i =0; i<tempConList.length; i++) {
                if(tempConList[i].label.toLowerCase().includes(searchstring.toLowerCase())) {
                    filteredConList.push(tempConList[i]);
                }
            }
            component.set("v.options", filteredConList);
        }
        else {
            component.set("v.options", tempOptn);
        }
        component.set("v.selectedOptions",component.get("v.selectedOptions"));
    }
})