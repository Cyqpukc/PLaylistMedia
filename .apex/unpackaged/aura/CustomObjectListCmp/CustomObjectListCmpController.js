({
	doInit : function(component, event, helper) {
        helper.getMMedia(component);
	},
    goToURL : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var recordId = selectedItem.dataset.record;
        var mediasId = selectedItem.dataset.mediaid;
        component.set("v.recordId", recordId);
        $A.createComponent(
            "c:MediaUploader",
            {
                "recordId" : recordId,
                "isCreateMediaContent" : true
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = [];
                    body.push(newCmp);
                    component.set("v.cmpUploadButton", body);
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
        alert(mediasId);
        if(mediasId){
            var arr = mediasId.split(',');
            var body = [];
            for(var i=0; i < arr.length; i++){
                console.log(arr[i]);
                  $A.createComponent(
                    "c:SimpleMediaCmp",
                    //"c:RelatedMediaCmp",
                    {
                        //"parentId" : response
                        "mediaId" : arr[i]
                    },
                    function(newCmp, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
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
        }
        component.set("v.showDetail", true);
    },
    goBack : function (component){
        component.set("v.showDetail", false);
        component.set("v.cmpInstances", []);
        component.set("v.cmpUploadButton", []);
    }
})