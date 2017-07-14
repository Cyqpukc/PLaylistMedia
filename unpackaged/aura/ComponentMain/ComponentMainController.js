({
    channelModalHandler : function (component, event, helper) {
        var modal = document.getElementById('manageVideosModal');
        if(!modal.classList.contains('slds-fade-in-open')){
            modal.classList.add('slds-fade-in-open');
            document.getElementById("BackgroundVideoPopUp").style.display = "block";
        }
    },
    doInit : function(component, event, helper) {
        helper.setVideos(component, '');
        helper.setChannels(component);
        helper.setShowPin(component);
    },
    filter : function(component, event, helper) {
        var searchTerm = component.get("v.search");
        component.set("v.hiddenRecomended", "true");
        helper.setVideos(component, searchTerm);
    },
    setChannel : function(component, event, helper){
        var refs = document.querySelectorAll('[data-channel-id]');
        for (var i = 0; i < refs.length; i++) {
            refs[i].classList.remove('active');
        }
        var chanelId = event.target.getAttribute('data-channel-id');
        component.set("v.activeChannelId", chanelId);
        var chanelName = event.target.getAttribute('data-channel-name');
        component.set("v.activeChannelName", chanelName);
        component.set("v.search", '');
        var href = document.querySelector('[data-channel-id="'+chanelId+'"]');
        href.classList.add('active');
        helper.setVideos(component, '');
    },
    change : function(component, event, helper){
        if(event.getParam("keyCode") != 13){
            return;
        }
        document.getElementById('button').focus();
        var searchTerm = component.get("v.search");
        component.set("v.hiddenRecomended", "true");
        helper.setVideos(component, searchTerm);
    },
    createNewChannel : function (component, event){
        var input = document.getElementById(event.target.getAttribute('data-input-id'));
        var a = component.get("c.addChannel");
        a.setParams({"channelName" : input.value.trim()});
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
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, 'show');
    },
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'show');
    },
    loadSvgScript : function(component, event, helper) {
        svg4everybody();
    },
    
    getVideoDetailEventHandler : function(component, event, helper) {
        var courseId = event.getParam("mediaId");
        var showPopup = event.getParam("showPopup");
        var modalId = event.getParam("modalId");
        
        helper.getVideoDetail(component, courseId, function(){
            if (showPopup) {
                var modal = document.getElementById(modalId);
                modal.classList.add('slds-fade-in-open');
                document.getElementById("BackgroundVideoPopUp").style.display = "block";
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
                document.getElementById("BackgroundVideoPopUp").style.display = "none";
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videos", response);
                    component.set("v.allvideos", response);
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
        var modal = document.getElementById('theRemoveModal');
        modal.classList.remove('slds-fade-in-open');
        document.getElementById("BackgroundVideoPopUp").style.display = "none";
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
                        var modal = document.getElementById('manageVideosModal');
                        modal.classList.remove('slds-fade-in-open');
                        document.getElementById("BackgroundVideoPopUp").style.display = "none";
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
    }
})