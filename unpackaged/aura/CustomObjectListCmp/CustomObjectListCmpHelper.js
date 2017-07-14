({
	getMMedia : function(component) {
		var a = component.get("c.getMultimedia");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.mediaItems", response);
                } else {
                    component.set("v.mediaItems", null);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.mediaItems", null);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
	},
    getMediaId : function(component, parentId) {
        var a = component.get("c.getMedia");
        
        alert('get');
        a.setParams({"multiMediaId" : parentId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    alert(response);
                     $A.createComponent(
                            "c:SimpleMediaCmp",
                            //"c:RelatedMediaCmp",
                            {
                                //"parentId" : response
                                "mediaId" : 'a014100000792gN'
                            },
                            function(newCmp, status, errorMessage){
                                //Add the new button to the body array
                                if (status === "SUCCESS") {
                                    var body = [];
                                    body.push(newCmp);
                                    component.set("v.cmpInstances", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    // Show error message
                                }
                            }
                        );
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
        window.setTimeout(
            $A.getCallback(function() {
                console.log(component.isValid());
            }), 100
        );
	}
})