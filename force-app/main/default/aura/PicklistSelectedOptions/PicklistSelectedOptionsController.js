({
    checkIfSelected : function(component, event, helper) {
        var selected = event.getParam("value");
        var value = component.get("v.title");
        if(selected && selected.length > 0){
            var index = selected.indexOf(value);
            if(index > -1){
                component.set("v.selected", true);
            }
            else{
                component.set("v.selected", false);
            }
        }
        else{
            component.set("v.selected", false);
        }
    }
})