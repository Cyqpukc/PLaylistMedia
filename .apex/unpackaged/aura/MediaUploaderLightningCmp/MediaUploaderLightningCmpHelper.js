({
    getPathPrefix: function (component) {
        var a = component.get("c.getPrefix");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    console.log('getPathPrefix ' + response);
                    component.set("v.prefix", response);
                } else {
                    component.set("v.prefix", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.prefix", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    getDomain: function (component) {
        var a = component.get("c.getSiteDomen");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                    console.log('getDomain ' +response);
                if (response){
                    component.set("v.domain", response);
                } else {
                    component.set("v.domain", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.domain", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    createMediaContent: function (component, courseId, parentId) {
        var a = component.get("c.createNewMediaContent");
        a.setParams({"courseId" : courseId, "parentId" : parentId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    console.log(response);
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    }
})