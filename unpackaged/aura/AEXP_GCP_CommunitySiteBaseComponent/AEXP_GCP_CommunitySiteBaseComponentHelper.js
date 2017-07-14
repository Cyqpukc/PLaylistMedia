({
	getSitePrefix: function(component){
        var action = component.get("c.siteBaseUrl");
     	action.setCallback(this, function(a){
            var state = a.getState();
        	if (state === "SUCCESS") {
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {                     
        			component.set("v.sitePrefix",rtnValue);     
                }
            } 
        });
        $A.enqueueAction(action); 
    }
})