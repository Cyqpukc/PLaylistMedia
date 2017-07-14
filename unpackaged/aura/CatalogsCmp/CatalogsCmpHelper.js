({
	setCatalogs : function(component, searchTerm) {
		var a = component.get("c.getCatalogs");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.catalogs", response);
                } else {
                    component.set("v.catalogs", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.catalogs", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
	},
    setChannels : function(component) {
        var a = component.get("c.getChannels");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.channel", response);
                } else {
                    component.set("v.channel", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.channel", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    createAllMediaCmp: function(component, catalogId, catalogName, channelId, channelName) {
        $A.createComponent(
            "c:AllMediaCmp",
            {
                "showRecommended" : false,
                "hiddenRecomended" : true,
                "showShared" : component.get("v.showShared"),
                "showPin" : component.get("v.showPin"),
                "showChannel" : component.get("v.showChannel"),
                "showProgress" : component.get("v.showProgress"),
                "isChannelListEmpty" : true,
                "showCatalogDetail" : catalogId != null,
                "activeCatalogId" : catalogId,
                "activeCatalogName" : catalogName,
                "activeChannelId" : channelId,
                "activeChannelName" : channelName,
                "shareButtonStyle" : component.get("v.shareButtonStyle"),
                "shareLinkType" : component.get("v.shareLinkType"),
                "siteId" : component.get("v.siteId")
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.set("v.mediaPopupCmpInstance", []);
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
    },
    createMediaPopupCmp: function(component, mediaSrc) {
        $A.createComponent(
            "c:MediaPopupCmp",
            {
                "mediaSrc" : mediaSrc,
                "showPopup" : true,
                "showPopupBackground" : true
            },
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = [];
                    body.push(newCmp);
                    component.set("v.mediaPopupCmpInstance", body);
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