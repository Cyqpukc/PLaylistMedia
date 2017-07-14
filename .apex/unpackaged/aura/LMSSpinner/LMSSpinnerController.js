({
    changeHandler : function(component, event, helper) {
        var sourceId = component.get("v.sourceId")
        var eventSourceId = event.getParam("sourceId");
        var isVisible = event.getParam("isVisible") === true;

        if(sourceId === eventSourceId){
            helper.showHideSpinner(component, isVisible);
        }
    }
})