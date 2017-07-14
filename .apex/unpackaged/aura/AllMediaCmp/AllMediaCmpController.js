({
    channelModalHandler : function (component, event, helper) {
        var modal = component.find("channelManagerInst");
        modal.showModal("theChannelsModal", true);
    },
    doInit : function(component, event, helper) {
        var countMedia = component.get("v.countMedia");
        if(countMedia < 1 || countMedia > 100){
            component.set("v.countMedia", 20);
        }
        helper.setVideos(component, '');
        helper.setChannels(component);
        helper.setShowPin(component);
        helper.setShowChannel(component);
        var courseId = '';
        var match = /[&#]Id(=([^&#]*)|&|#|$)/.exec(location.href);
        if (match != null && match.length > 2) {
            courseId = match[2];
        }
        
        if (courseId != '' && courseId.length <= 18) {
            var a = component.get("c.getLink");
            a.setParams({"courseId" : courseId});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    console.log('response: '+response);
                    if (response && response != '') {
                        if(helper.isMobile(component)){
                            window.open(response);
                        } else{
                            component.set("v.currentMediaSrc", response+'&autoplay=0');
                            component.set("v.showMediaPopup", true);
                            component.set("v.showMediaPopupBackground", true);
                        }
                    } else {
                        $A.log('Invalid response');
                    }
                }
            });
            $A.enqueueAction(a);
        }
        
    },
    showMoreMedia : function(component, event, helper) {
        helper.showMore(component);
    },
    filter : function(component, event, helper) {
        helper.showSpinnerAllMedia(component);
        var searchTerm = component.get("v.search");
        component.set("v.hiddenRecomended", "true");
        helper.setVideos(component, searchTerm);
    },
    setChannel : function(component, event, helper){
        var spinner = component.find('spinnerAllMedia');
        $A.util.removeClass(spinner, 'slds-hide');
        var chanelId = event.target.getAttribute('data-channel-id');
        component.set("v.activeChannelId", chanelId);
        var chanelName = event.target.getAttribute('data-channel-name');
        component.set("v.activeChannelName", chanelName);
        component.set("v.search", '');
        component.set("v.showCatalogDetail", false);
        component.set("v.activeCatalogId", '');
        helper.setVideos(component, '');
    },
    change : function(component, event, helper){
        if(event.getParam("keyCode") != 13){
            return;
        }
        var spinner = component.find('spinnerAllMedia');
        $A.util.removeClass(spinner, 'slds-hide');
        component.find('button').getElement().focus();
        var searchTerm = component.get("v.search");
        component.set("v.hiddenRecomended", "true");
        helper.setVideos(component, searchTerm);
    },
    loadSvgScript : function(component, event, helper) {
        svg4everybody();
    },

    getVideoDetailEventHandler : function(component, event, helper) {
        var courseId = event.getParam("mediaId");
        var showPopup = event.getParam("showPopup");
        var modalId = event.getParam("modalId");
        var modal = component.find("channelManagerInst");

        helper.getVideoDetail(component, courseId, function(){
            if (showPopup) {
                modal.showModal(modalId, true);
            }
        });
    },
    setChannelsEventHandler : function(component, event, helper) {
        helper.setChannels(component);
    },
    removeMediaFromChanEventHandler : function(component, event, helper) {
        var mediaId = event.getParam("mediaId");

        var a = component.get("c.removeMediaFromChannel");
        a.setParams({"channelId" : component.get("v.activeChannelId"), "mediaId" : mediaId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var modal = component.find("channelManagerInst");
                modal.showModal("theRemoveModal", false);
                var response = action.getReturnValue();
                if (response){
                    component.set("v.allMedia", response);
                    helper.updateMedia(component);
                } else {
                    component.set("v.videos", []);
                    component.set("v.allvideos", []);
                    $A.log('Invalid response');
                }
                helper.setChannels(component);
            } else {
                component.set("v.videos", []);
                component.set("v.allvideos", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
        modal.showModal("theRemoveModal", false);
    },
    addMediaToChannelEventHandler : function(component, event, helper) {
        var channelId = event.getParam("channelId");
        var mediaId = event.getParam("mediaId");
        var channelName = event.getParam("channelName");
        var a = component.get("c.addMediaToChannel");
        a.setParams({"channelId" : channelId, "mediaId" : mediaId, "channelName" : channelName});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (channelName.length > 0) {
                    helper.setChannels(component);
                }
                if (!response){
                    $A.log('Invalid response');
                }
                helper.getVideoDetail(component, mediaId);
                helper.setChannels(component);
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    deleteChannelEventHandler: function(component, event, helper) {
        var modal = component.find("channelManagerInst");
        var attr = event.getParam("channelId");
        var a = component.get("c.removeChannel");
        a.setParams({"channelId" : attr});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.channel", response);
                    if(response.length == 0){
                        component.set("v.isChannelListEmpty", true);
                        modal.showModal("theChannelsModal", false);
                    } else {
                        component.set("v.isChannelListEmpty", false);
                    }
                    console.log(attr);
                    console.log(component.get("v.activeChannelId"));
                    if(response.length == 0 || attr == component.get("v.activeChannelId")){
                        component.set("v.activeChannelId", "All");
                        component.set("v.activeChannelName", "All");
                        helper.setVideos(component, '');
                    }
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
    renameChannelEventHandler: function(component, event, helper) {
        var channelId = event.getParam("channelId");
        var channelName = event.getParam("channelName");
        var a = component.get("c.changeNameChannel");
        a.setParams({"channelId" : channelId, "newName" : channelName});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                if(channelId == component.get("v.activeChannelId")){
                    component.set("v.activeChannelName", channelName);
                }
                helper.setChannels(component);
            } else {
                helper.setChannels(component);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    openVideoModalHandler: function(component, event, helper) {
        var mediaLink = event.getParam("mediaId");
        var showPopup = event.getParam("showPopup");
        component.set("v.currentMediaSrc", mediaLink);
        component.set("v.showMediaPopup", showPopup);
        component.set("v.showMediaPopupBackground", showPopup);
    },
    showPopupBackgroundHandler: function(component, event, helper) {
        var showPopup = event.getParam("showPopup");
        component.set("v.showMediaPopupBackground", showPopup);
    }
})