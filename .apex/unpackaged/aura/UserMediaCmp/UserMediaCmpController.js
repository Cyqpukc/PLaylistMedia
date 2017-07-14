({
    doInit : function(component, event, helper) {
        var isProfile = component.get("v.isForProfilePage");
        if(isProfile){
            component.set("v.showButtonViewMoreViewed", false);
            component.set("v.showButtonViewMoreUploaded", false);
            component.set("v.countMedia", 3);
        } else{
            var countMedia = component.get("v.countMedia");
            if(countMedia < 1 || countMedia > 100){
                component.set("v.countMedia", 20);
            }
            var match = /[?&]userId(=([^&#]*)|&|#|$)/.exec(location.href);
           if (match != null && match.length > 2) {
               component.set("v.userId", match[2]);
           }
        }
        helper.setIsSameUserVariable(component);
        helper.setMedia(component);
        component.set("v.isInitComplete", true);
        helper.getPathPrefix(component);
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
    },
    showMoreMediaViewed : function(component, event, helper) {
        helper.showMoreViewed(component, event, helper);
    },
    showMoreMediaUploaded : function(component, event, helper) {
        helper.showMoreUploaded(component, event, helper);
    },
    loadSvgScript : function(component, event, helper) {
        svg4everybody();
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
    },
    goToURL : function(component, event, helper) {
        var link = "/user-media?userId=" + component.get("v.userId");
        if (link != '') {
            var navEvt = $A.get("e.force:navigateToURL");
            navEvt.setParams({
                "url": link,
                "isredirect": true
            })
            navEvt.fire();
        }
    }
})