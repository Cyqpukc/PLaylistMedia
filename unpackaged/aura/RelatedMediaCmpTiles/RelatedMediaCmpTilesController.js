({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.parentId");
        if(recordId === undefined){
            recordId = component.get("v.recordId");
        }
		helper.setMedia(component, recordId);
	},
	loadSvgScript : function(component, event, helper) {
        svg4everybody();
    }
})