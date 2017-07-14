({
    setShowShareButton : function(component) {
        var a = component.get("c.getShareAccess");
        var isShowShare = component.get("v.showShared");
        a.setParams({"shareButtonStyle" : component.get("v.shareButtonStyle")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && isShowShare){
                	component.set("v.showShared", true);
                } else {
                    component.set("v.showShared", false);
                }
            } else {
                component.set("v.showShared", false);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    validateEmail : function (email) {
        var re = /([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})/;
        return re.test(email);
    },
    getMediaLink : function(component, courseId){
        var a = component.get("c.getMediaLink");
        var currentUrl = window.location.host;
        a.setParams({"courseId" : courseId, "currentUrl" : currentUrl});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.mediaLink", response);
                } else {
                    component.set("v.mediaLink", null);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.mediaLink", null);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    getPublicLink : function(component, courseId, siteId){
        var a;
        var shareLinkType = component.get("v.shareLinkType");
        if (shareLinkType == 'PopUp') {
            a = component.get("c.getPublicLinkAp");
            var localUrl = 'https://'+ location.hostname + location.pathname;
            if (window.location.href.indexOf('one.app') != -1){
                localUrl = location.href;
            }
            a.setParams({"siteId" : siteId, "myCourseId" : courseId, "domain" : localUrl, "autoplay" : "autoplay=0"});
        } else {
            a = component.get("c.getPublicLinkNewWindow");
            a.setParams({"siteId" : siteId, "myCourseId" : courseId});
        }
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.publicLink", response);
                } else {
                    component.set("v.publicLink", null);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.publicLink", null);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    deleteMedia : function(component, courseId){
        var a = component.get("c.deleteRelatedMedia");
        a.setParams({"courseId" : courseId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                if (window.location.href.indexOf('native/bridge') > 0) {
                    $A.get('e.force:refreshView').fire();
                } else {
                    window.location.reload();
                }
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setIsMobile : function(component){
        var isMob = /Android|iPhone|iPad|iPod|IEMobile|webOS|BlackBerry|Opera Mini/i.test(navigator.userAgent);
        component.set("v.isMobile", isMob);
    },
    showPopupBackground: function(component, show) {
        var cmpEvent = component.getEvent("showPopupBackgroundEvent");
        cmpEvent.setParams({
        	"showPopup" : show
        });
        cmpEvent.fire();
    }
})