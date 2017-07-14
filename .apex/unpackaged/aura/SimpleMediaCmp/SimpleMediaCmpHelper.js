({
    setFrameSize : function(component) {
        var frm = component.find("CustomPlayerIframe");
        if (frm) {
            frm = frm.getElement();
            var frameHeight = parseFloat(frm.offsetWidth) / 16.0 * 9.0;
            component.set("v.frameHeight", frameHeight);
            component.set("v.frameStyleHeight", 'height:' + frameHeight  + 'px;');
        }
    },
    getMediaLink : function(component){
        var a = component.get("c.getEmbeddedLink");
        var courseId = component.get("v.mediaId");
        if(courseId.length > 0){
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
        }
    },
    getPublicLink : function(component, siteId){
        var a;
        var shareLinkType = component.get("v.shareLinkType");
        var courseId = component.get("v.mediaId");
        if (shareLinkType == 'PopUp') {
            a = component.get("c.getPublicLinkAp");
            a.setParams({"siteId" : siteId, "myCourseId" : courseId, "domain" : 'https://'+location.hostname + location.pathname, "autoplay" : "autoplay=0"});
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
                if(component.get("v.mediaId").length > 0){
                    component.set(
                        "v.mediaSrc",
                        component.get("v.prefix") + '/apex/scormanywhere__SCORM_Player?inline=1&autoplay=0&courseId='
                        + component.get("v.mediaId")
                    );
                }
            } else {
                if (component.isValid()) {
                    component.set("v.prefix", '');
                    if(component.get("v.mediaId").length > 0){
                        component.set(
                            "v.mediaSrc",
                            component.get("v.prefix") + '/apex/scormanywhere__SCORM_Player?inline=1&autoplay=0&courseId='
                                + component.get("v.mediaId")
                        );
                    }
                    $A.log(action.getState());
                }
            }
        });
        $A.enqueueAction(a);
    },
    setClass: function(component, elementId, className) {
        var element = component.find(elementId);
        $A.util.toggleClass(element, className);
    },
    checkCourseId: function(component, elementId, className) {
        var a = component.get("c.getCourse");
        a.setParams({"courseId" : component.get("v.mediaId")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                console.log(response);
                if (response != null){
                } else {
                    component.set("v.isError", true);
                    component.set("v.isShowPlayer", false);
                    $A.log('Invalid response');
                }
            } else {
                if (component.isValid()) {
                    component.set("v.isError", true);
                    component.set("v.isShowPlayer", false);
                    $A.log(action.getState());
                }
            }
        });
        $A.enqueueAction(a);
    },
    setSettings : function(component) {
        var useSettings = component.get("v.isGlobalShareButtonSetting");
        useSettings = true;
        if(useSettings) {
            var a = component.get("c.getGlobalShareButtonSettings");
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                console.log('response');
                console.log(response);
                    if(response[0] != null) {
                        component.set("v.shareButtonStyle", response[0]);
                    }
                    if(response[1] != null) {
                        component.set("v.siteId", response[1]);
                    }
                } else {
                    $A.log(action.getState());
                }
            });
            $A.enqueueAction(a);
        }
    },
    validateEmail : function (email) {
        var re = /([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})/;
        return re.test(email);
    },
})