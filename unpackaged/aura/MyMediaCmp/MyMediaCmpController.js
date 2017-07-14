({
    channelModalHandler : function (component, event, helper) {
        var modal = component.find("channelManagerInst");
        modal.showModal("theChannelsModal", true);
    },
    doInit : function(component, event, helper) {
        helper.showSpinnerMymedia(component);
        helper.setVideos(component, true);
        if(component.get("v.showChannel")){
            helper.setChannels(component);
        }
        helper.setShowPin(component);
        helper.isMobile(component);
        if (component.get("v.isMobile")) {
            component.set("v.mediaLimit", 100);
        } else {
            component.set("v.mediaLimit", 4);
        }
        if (window.location.href.indexOf('one.app') == -1){
            var courseId = '';
            var match = /[?&#]Id(=([^&#]*)|&|#|$)/.exec(location.href);
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
                            component.set("v.currentMediaSrc", response+'&autoplay=0');
                            component.set("v.showMediaPopup", true);
                            component.set("v.showMediaPopupBackground", true);
                        } else {
                            $A.log('Invalid response');
                        }
                    }
                });
                $A.enqueueAction(a);
            }
        }
    },
    filter : function(component, event, helper) {
        helper.setVideos(component, false);
    },
    setChannel : function(component, event, helper){
        helper.showSpinnerMymedia(component);
        var chanelId = event.target.getAttribute('data-channel-id');
        component.set("v.activeChannelId", chanelId);
        var chanelName = event.target.getAttribute('data-channel-name');
        component.set("v.activeChannelName", chanelName);
        component.set("v.search", '');
        helper.setVideos(component, true);
    },
    change : function(component, event, helper){
        var searchTerm = component.get("v.search").toLowerCase();
        var searchcourse = [];
        if(searchTerm.length > 3){
            component.set("v.searchName", []);
            var videoNames = component.get("v.videoNames");
            for (var i = 0; i < videoNames.length; i++) {
                if(videoNames[i].toLowerCase().search( searchTerm ) != -1){
                    searchcourse.push(videoNames[i]);
                }
            }
            console.log(searchcourse);
            if(searchcourse.length > 0){
                component.set("v.searchName", searchcourse);
            }
        } else{
            component.set("v.searchName", []);
        }
        if(event.getParam("keyCode") != 13){
            return;
        }
        helper.setVideos(component, false);
    },
    search : function(component, event, helper){
        var index = event.target.getAttribute('data-index');
        var courseName = component.get("v.searchName")[index];
        component.set("v.search", courseName);
        component.set("v.searchName", []);
        helper.setVideos(component, false);
    },
    blur : function(component, event, helper){
        console.log('blur called');
        setTimeout(
            $A.getCallback(function() {
              component.set("v.searchName", []);
          }), 600
        );
    },
    changeManageTrue : function (component, event, helper) {
    	component.set("v.isManage", true);
    },

    changeManageFalse : function (component, event, helper) {
    	component.set("v.isManage", false);
    },

    openChannelsMobile : function (component, event, helper) {
        helper.setClass(component, "link_popup", "slds-hide");
    },

    openSearchFormMobile : function (component, event, helper) {
        helper.setClass(component, "mobileSearchForm", "slds-hide");
    },

    setChannelMobile : function(component, event, helper){
        component.set("v.mobileMediaHeader", 'My Media');

        var chanelId = event.target.getAttribute('data-channel-id');
        component.set("v.activeChannelId", chanelId);
        var chanelName = event.target.getAttribute('data-channel-name');
        component.set("v.activeChannelName", chanelName);
        component.set("v.search", '');

        helper.setVideos(component, true);

        var newMediaHeader = component.get("v.mobileMediaHeader");
        newMediaHeader = newMediaHeader + ' > ' + chanelName;
        component.set("v.mobileMediaHeader", newMediaHeader);
        helper.setClass(component, "link_popup", "slds-hide");
    },
    selectCarouselItem : function(component, event, helper) {
        component.set("v.search", "");
        helper.showSpinnerMymedia(component);
        var transcriptId = event.target.getAttribute("data-transcript-id");;
        var a = component.get("c.updateTranscript");
        a.setParams({"transcriptId" : transcriptId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                console.log('updated');
            } else {
                $A.log(action.getState());
            }
            helper.setVideos(component, false);
            helper.setCarousel(component);
        });
        $A.enqueueAction(a);
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
        helper.showSpinnerMymedia(component);
        helper.setChannels(component);
    },
    removeMediaFromChanEventHandler : function(component, event, helper) {
        helper.showSpinnerMymedia(component);
        var mediaId = event.getParam("mediaId");
        var a = component.get("c.removeMediaFromChannel");
        a.setParams({"channelId" : component.get("v.activeChannelId"), "mediaId" : mediaId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                component.set("v.showMediaPopupBackground", false);
                helper.setVideos(component, false);
                helper.setChannels(component);
            } else {
                component.set("v.videos", []);
                component.set("v.allvideos", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
        var modal = component.find("channelManagerInst");
        modal.showModal("theRemoveModal", false);
    },
    addMediaToChannelEventHandler : function(component, event, helper) {
        helper.showSpinnerMymedia(component);
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
        helper.showSpinnerMymedia(component);
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
                        helper.setVideos(component, true);
                    } else{
                        helper.hideSpinnerMymedia(component);
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
        helper.showSpinnerMymedia(component);
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
        console.log(mediaLink);
        component.set("v.currentMediaSrc", mediaLink);
        component.set("v.showMediaPopup", showPopup);
        component.set("v.showMediaPopupBackground", showPopup);
    },
    showPopupBackgroundHandler: function(component, event, helper) {
        var showPopup = event.getParam("showPopup");
        component.set("v.showMediaPopupBackground", showPopup);
    }
})