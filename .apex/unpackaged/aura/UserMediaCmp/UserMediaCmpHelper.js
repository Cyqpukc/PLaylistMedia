({
    setMedia : function(component) {
        var userId = component.get("v.userId");
        var a = component.get("c.getUploadedMedia");
        a.setParams({"userId" : userId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    // console.log('u '+response);
                    component.set("v.mediaUploadedIds", response);
                    this.showMoreUploaded(component);
                } else {
                    component.set("v.mediaUploadedIds", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.mediaUploadedIds", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
        if(component.get("v.showRecentViewed")){
            a = component.get("c.getViewedMedia");
            a.setParams({"userId" : userId});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response){
                        // console.log('v '+response);
                        component.set("v.mediaViewedIds", response);
                        this.showMoreViewed(component);
                    } else {
                        component.set("v.mediaViewedIds", []);
                        $A.log('Invalid response');
                    }
                } else {
                    component.set("v.mediaViewedIds", []);
                    $A.log(action.getState());
                }
            });
            $A.enqueueAction(a);
        }
    },
    getPathPrefix: function (component) {
        var a = component.get("c.getPrefix");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
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
    showMoreViewed : function(component, event, helper) {
        this.showSpinnerUserMedia(component);
        var a = component.get("c.getTranscripts");
        var currentIndexViewed = component.get("v.currentIndexViewed");
        var countMedia = component.get("v.countMedia");
        var mediaViewedIds = component.get("v.mediaViewedIds");
        // console.log("view");
        // console.log(currentIndexViewed);
        // console.log(mediaViewedIds);
        var mediaIds;
        if(mediaViewedIds.length > currentIndexViewed+countMedia){
            mediaIds = mediaViewedIds.slice(currentIndexViewed, currentIndexViewed+countMedia);
        } else{
            mediaIds = mediaViewedIds.slice(currentIndexViewed, mediaViewedIds.length);
            component.set("v.showButtonViewMoreViewed", false);
        }
        // console.log(mediaIds);
        a.setParams({"transcriptIds" : mediaIds});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    console.log('v '+response);
                    if(currentIndexViewed == 0){
                        component.set("v.viewedMedia", response);
                        var index = component.get("v.currentIndexViewed");
                        // console.log('index '+index);
                        // console.log(response.length);
                        component.set("v.currentIndexViewed",index+response.length);
                    } else {
                        $A.createComponent(
                            "c:MediaCmp",
                            {
                                "mediaItems": response,
                                "showShared": component.get("v.showShared"),
                                "showPin": component.get("v.showPin"),
                                "showProgress": component.get("v.showProgress"),
                                "showChannel": component.get("v.showChannel"),
                                "shareButtonStyle": component.get("v.shareButtonStyle"),
                                "isCourseNameLink": component.get("v.isCourseNameLink"),
                                "isCreatedByLink": component.get("v.isCreatedByLink")
                            },
                            function(newCmp, status, errorMessage) {
                                var body = component.get("v.cmpViewInstances");
                                component.set("v.cmpViewInstances", body);
                                if (status === "SUCCESS") {
                                    // newCmp is a reference to another component
                                    body.push(newCmp);
                                    component.set("v.cmpViewInstances", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    // Show error message
                                }
                            });
                        component.set("v.currentIndexViewed",component.get("v.currentIndexViewed")+response.length);
                    }
                } else {
                    component.set("v.mediaViewedIds", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.mediaViewedIds", []);
                $A.log(action.getState());
            }
            this.hideSpinnerUserMedia(component);
        });
        $A.enqueueAction(a);
    },
    showMoreUploaded : function(component, event, helper) {
        this.showSpinnerUserMedia(component);
        var a = component.get("c.getCourses");
        var currentIndexUploaded = component.get("v.currentIndexUploaded");
        var countMedia = component.get("v.countMedia");
        var mediaUploadedIds = component.get("v.mediaUploadedIds");

        // console.log("Uploaded");
        // console.log(currentIndexUploaded);
        // console.log(mediaUploadedIds);
        // console.log(countMedia);
        var mediaIds;
        if(mediaUploadedIds.length > currentIndexUploaded+countMedia){
            mediaIds = mediaUploadedIds.slice(currentIndexUploaded, currentIndexUploaded+countMedia);
        } else{
            mediaIds = mediaUploadedIds.slice(currentIndexUploaded, mediaUploadedIds.length);
            component.set("v.showButtonViewMoreUploaded", false);
        }
        // console.log(mediaIds);
        a.setParams({"courseIds" : mediaIds, "uId" : component.get("v.userId")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    // console.log('u '+response);
                    if(currentIndexUploaded == 0){
                        component.set("v.uploadedMedia", response);
                        var index = component.get("v.currentIndexUploaded");
                        // console.log('index u '+index);
                        // console.log(response.length);
                        component.set("v.currentIndexUploaded",index+response.length);
                    } else {
                        $A.createComponent(
                            "c:MediaCmp",
                            {
                                "mediaItems": response,
                                "showShared": component.get("v.showShared"),
                                "showPin": component.get("v.showPin"),
                                "showProgress": component.get("v.showProgress"),
                                "showChannel": component.get("v.showChannel"),
                                "shareButtonStyle": component.get("v.shareButtonStyle"),
                                "isCourseNameLink": component.get("v.isCourseNameLink"),
                                "isCreatedByLink": component.get("v.isCreatedByLink")
                            },
                            function(newCmp, status, errorMessage) {
                                var body = component.get("v.cmpUploadInstances");
                                component.set("v.cmpUploadInstances", body);
                                if (status === "SUCCESS") {
                                    // newCmp is a reference to another component
                                    body.push(newCmp);
                                    component.set("v.cmpUploadInstances", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    // Show error message
                                }
                            });
                        component.set("v.currentIndexUploaded",component.get("v.currentIndexUploaded")+response.length);
                    }
                } else {
                    component.set("v.mediaUploadedIds", []);
                    // component.set("v.videos", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.mediaUploadedIds", []);
                $A.log(action.getState());
            }
            this.hideSpinnerUserMedia(component);
        });
        $A.enqueueAction(a);
    },
    setIsSameUserVariable: function (component) {
        var a = component.get("c.getUserId");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    // console.log(response);
                    var userId = component.get("v.userId");
                    if (response.indexOf(userId) !== -1) {
                        component.set("v.isSameUser", true);
                        // console.log('same user');
                    } else {
                        component.set("v.isSameUser", false);
                        // console.log('not same user');
                    }
                } else {
                    component.set("v.isSameUser", false);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.isSameUser", false);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    showSpinnerUserMedia : function (component) {
        var spinner = component.find('spinnerUserMedia');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    hideSpinnerUserMedia : function (component) {
        var spinner = component.find('spinnerUserMedia');
        $A.util.addClass(spinner, 'slds-hide');
    },
})