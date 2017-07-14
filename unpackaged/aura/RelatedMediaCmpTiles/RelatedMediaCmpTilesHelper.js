({
	setMedia : function(component, parentId) {
		var a = component.get("c.getContent");
        a.setParams({"parentId" : parentId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                console.log(response);
                if (response){
                    component.set("v.media", response);
                } else {
                    component.set("v.media", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.media", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
	}
})