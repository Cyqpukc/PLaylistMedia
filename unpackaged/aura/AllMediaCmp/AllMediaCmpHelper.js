({
    getVideoDetail : function(component, courseId, _callback) {
        this.showSpinnerAllMedia(component);
        var a = component.get("c.getVideoDetail");
        a.setParams({"courseId" : courseId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videoDetail", response);
                    if (_callback) {
                        _callback();
                    }
                } else {
                    component.set("v.videoDetail", null);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.videoDetail", null);
                $A.log(action.getState());
            }
            this.hideSpinnerAllMedia(component);
        });
        $A.enqueueAction(a);
    },
    setVideos : function(component, searchTerm) {
        this.showSpinnerAllMedia(component);
        searchTerm = searchTerm.trim();
        component.set("v.cmpInstances", []);
        component.set("v.currentIndex", 0);
        var a = component.get("c.getAllVideos");
        var activeChannel = component.get("v.activeChannelId");
        var activeCatalog = component.get("v.activeCatalogId");
        a.setParams({"searchTerm" : searchTerm, "channelId" : activeChannel, "catalogId" : activeCatalog});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.allMedia", response);
                    this.showMore(component);
                } else {
                    component.set("v.allMedia", []);
                    component.set("v.showButtonViewMore", false);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.allMedia", []);
                component.set("v.showButtonViewMore", false);
                $A.log(action.getState());
                this.hideSpinnerAllMedia(component);
            }
        });
        $A.enqueueAction(a);

        if(component.get("v.showRecommended")){
            var maxsizeRecommended = component.get("v.maxCountRecommendedVideos");
            var r = component.get("c.getRecomendedVideos");
            r.setParams({"searchTerm" : searchTerm, "maxCount" : maxsizeRecommended});
            r.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response){
                        component.set("v.recomendedVideos", response);
                    } else {
                        component.set("v.recomendedVideos", []);
                        $A.log('Invalid response');
                    }
                } else {
                    component.set("v.recomendedVideos", []);
                    $A.log(action.getState());
                }
            });
            this.hideSpinnerAllMedia(component);
            $A.enqueueAction(r);
        }
    },
    showMore : function(component) {
        this.showSpinnerAllMedia(component);
        component.set("v.showButtonViewMore", true);
        var a = component.get("c.getMedia");
        var currentIndex = component.get("v.currentIndex");
        var countMedia = component.get("v.countMedia");
        var allMedia = component.get("v.allMedia");
        var mediaIds;
        if(allMedia.length > currentIndex+countMedia){
            mediaIds = allMedia.slice(currentIndex, currentIndex+countMedia);
        } else{
            mediaIds = allMedia.slice(currentIndex, allMedia.length);
            component.set("v.showButtonViewMore", false);
        }
        a.setParams({"mediaIds" : mediaIds});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    if(currentIndex == 0){
                        component.set("v.videos", response);
                        var index = component.get("v.currentIndex");
                        component.set("v.currentIndex",index+response.length);
                        this.hideSpinnerAllMedia(component);
                    } else {
                        $A.createComponent(
                            "c:MediaCmp",
                            {
                                "mediaItems": response,
                                "siteId": component.get("v.siteId"),
                                "showShared": component.get("v.showShared"),
                                "showPin": component.get("v.showPin"),
                                "showProgress": component.get("v.showProgress"),
                                "showChannel": component.get("v.showChannel"),
                                "activeChannelId": component.get("v.activeChannelId"),
                                "shareButtonStyle": component.get("v.shareButtonStyle"),
                                "isCourseNameLink": component.get("v.isCourseNameLink"),
                                "isCreatedByLink": component.get("v.isCreatedByLink"),
                                "shareLinkType": component.get("v.shareLinkType")
                            },
                            function(newCmp, status, errorMessage) {
                                var body = component.get("v.cmpInstances");
                                component.set("v.cmpInstances", body);
                                if (status === "SUCCESS") {
                                    // newCmp is a reference to another component
                                    body.push(newCmp);
                                    component.set("v.cmpInstances", body);
                                    var spinner = component.find('spinner');
                                    $A.util.addClass(spinner, 'slds-hide');
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
                        this.hideSpinnerAllMedia(component);
                        component.set("v.currentIndex",component.get("v.currentIndex")+response.length);
                    }
                } else {
                    component.set("v.allMedia", []);
                    this.hideSpinnerAllMedia(component);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.allMedia", []);
                this.hideSpinnerAllMedia(component);
                $A.log(action.getState());
            }
		});
        $A.enqueueAction(a);
    },
    updateMedia : function(component) {
        this.showSpinnerAllMedia(component);
        var a = component.get("c.getMedia");
        var currentIndex = component.get("v.currentIndex");
        var countMedia = component.get("v.countMedia");
        var allMedia = component.get("v.allMedia");
        var mediaIds = allMedia.slice(0, currentIndex);
        a.setParams({"mediaIds" : mediaIds});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videos", response);
                    component.set("v.cmpInstances", []);
                    component.set("v.currentIndex", response.length);
                    component.set("v.showButtonViewMore", allMedia.length > response.length);
                    this.hideSpinnerAllMedia(component);
                } else {
                    component.set("v.allMedia", []);
                    this.hideSpinnerAllMedia(component);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.allMedia", []);
                this.hideSpinnerAllMedia(component);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setChannels : function(component) {
        this.showSpinnerAllMedia(component);
        var a = component.get("c.getChannels");
        a.setParams({"catalogId" : component.get("v.activeCatalogId")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.channel", response);
                    if(response.length == 0){
                        component.set("v.isChannelListEmpty", true);
                    } else {
                        component.set("v.isChannelListEmpty", false);
                    }
                } else {
                    component.set("v.channel", []);
                    $A.log('Invalid response');
                }
                this.hideSpinnerAllMedia(component);
            } else {
                component.set("v.channel", []);
                $A.log(action.getState());
                this.hideSpinnerAllMedia(component);
            }
        });
        $A.enqueueAction(a);
    },
    setShowPin : function(component) {
        var a = component.get("c.getPinAccess");
        var isShowPin = component.get("v.showPin");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && isShowPin){
                	component.set("v.showPin", true);
                } else {
                    component.set("v.showPin", false);
                }
            } else {
                component.set("v.showPin", false);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setShowChannel : function(component) {
        var a = component.get("c.getUserType");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response.toLowerCase() != 'guest' && component.get("v.showChannel")){
                	component.set("v.showChannel", true);
                } else {
                    component.set("v.showChannel", false);
                }
            } else {
                component.set("v.showPin", false);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    showSpinnerAllMedia : function (component) {
        var spinner = component.find('spinnerAllMedia');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    hideSpinnerAllMedia : function (component) {
        var spinner = component.find('spinnerAllMedia');
        $A.util.addClass(spinner, 'slds-hide');
    },
    isMobile : function(component){
        var isMob = /Android|iPhone|iPad|iPod|IEMobile|webOS|BlackBerry|Opera Mini/i.test(navigator.userAgent);
        return isMob;
    },
})