({
    getSessionId: function (component) {
        var a = component.get("c.getSessionId");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                console.log(response);
                if (response){
                    component.set("v.sessionId", response);
                } else {
                    component.set("v.sessionId", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.sessionId", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
})