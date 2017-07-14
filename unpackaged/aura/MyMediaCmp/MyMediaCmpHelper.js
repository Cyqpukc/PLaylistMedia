({
    getVideoDetail : function(component, courseId, _callback) {
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
        });
        $A.enqueueAction(a);
    },
    setVideos : function(component, isResetNames) {
        var searchTerm = component.get("v.search");
        var a = component.get("c.getAllUserVideos");
        var activeChannel = component.get("v.activeChannelId");
        var videoNames = [];
        component.set("v.searchName", []);
        a.setParams({"searchTerm" : searchTerm, "channelId" : activeChannel});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videos", response);
                    if (isResetNames) {
                        for (var i = 0; i < response.length; i++) {
                            videoNames.push(response[i].name);
                        }
                        component.set("v.videoNames", videoNames);
                    }
                    this.hideSpinnerMymedia(component);

                } else {
                    component.set("v.videos", []);
                    if (isResetNames) {
                        component.set("v.videoNames", []);
                    }
                    this.hideSpinnerMymedia(component);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.videos", []);
                this.hideSpinnerMymedia(component);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);

        var a = component.get("c.getCarouselData");
        var activeChannel = component.get("v.activeChannelId");
        a.setParams({"searchTerm" : searchTerm, "channelId" : activeChannel});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && response.pages){
                    component.set("v.carouselData", response.pages);
                } else {
                    component.set("v.carouselData", null);
                }
            } else {
                component.set("v.carouselData", null);
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
                    if(response.length == 0){
                        component.set("v.isChannelListEmpty", true);
                    } else {
                        component.set("v.isChannelListEmpty", false);
                    }
                } else {
                    component.set("v.channel", []);
                    $A.log('Invalid response');
                }
                this.hideSpinnerMymedia(component);
            } else {
                component.set("v.channel", []);
                this.hideSpinnerMymedia(component);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setCarousel : function(component, searchTerm) {

    },
    setShowPin : function(component) {
        var a = component.get("c.getPinAccess");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && component.get("v.showPin")){
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
    isMobile : function(component){
        var isMob = /Android|iPhone|iPad|iPod|IEMobile|webOS|BlackBerry|Opera Mini/i.test(navigator.userAgent);
        component.set("v.isMobile", isMob);
    },
    setClass: function(component, elementId, className) {
        var elements = component.find(elementId);
        $A.util.toggleClass(elements, className);
    },
    showSpinnerMymedia : function (component, event, helper) {
        var spinner = component.find('spinner');
        console.log('asdasd '+spinner);
        $A.util.removeClass(spinner, 'slds-hide');
    },
    hideSpinnerMymedia : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },
})