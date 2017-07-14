({
	createUploaderCmp: function(component, catalogId, catalogName) {
        $A.createComponent(
            "c:MediaUploader",
            {
                "isCreateMediaContent" : true,
                "recordId" : '{!recordId}',
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.cmpInstances");
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
    }
})