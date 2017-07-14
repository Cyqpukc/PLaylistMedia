({
    getSessionId: function (component) {
        var a = component.get("c.getSessionId");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.sessionId", response);
                } else {
                    component.set("v.sessionId", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.sessionId", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    getAccessToUpload: function (component) {
        var a = component.get("c.uploadToSF");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.isUploadSFContent", response);
                } else {
                    $A.log('Invalid response');
                }
            } else {
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
                component.set(
                    "v.uploaderIframeSrc",
                    'https://' + component.get("v.domain") + component.get("v.prefix")
                        + '/apex/vtui__mediauploaderSF?originalDomain='+component.get("v.originalDomain")
                );
            } else if (component.isValid()){
                component.set("v.prefix", '');
                component.set(
                    "v.uploaderIframeSrc",
                    'https://' + component.get("v.domain") + component.get("v.prefix")
                        + '/apex/vtui__mediauploaderSF?originalDomain='+component.get("v.originalDomain")
                );
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    getDomain: function (component) {
        var a = component.get("c.getSiteDomen");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                    console.log('getDomain ' +response);
                if (response){
                    component.set("v.domain", response);
                } else {
                    component.set("v.domain", '');
                    $A.log('Invalid response');
                }
                component.set(
                    "v.uploaderIframeSrc",
                    'https://' + component.get("v.domain") + component.get("v.prefix")
                        + '/apex/vtui__mediauploaderSF?originalDomain='+component.get("v.originalDomain")
                );
            } else if (component.isValid()){
                component.set("v.domain", '');
                component.set(
                    "v.uploaderIframeSrc",
                    'https://' + component.get("v.domain") + component.get("v.prefix")
                        + '/apex/vtui__mediauploaderSF?originalDomain='+component.get("v.originalDomain")
                );
                $A.log(action.getState());
            }
            component.set("v.isLoaded", true);
        });
        $A.enqueueAction(a);
    },
    createMediaContent: function (component, courseId, parentId) {
        this.showSpinnerUploader(component);
        var a = component.get("c.createNewMediaContent");
        a.setParams({"courseId" : courseId, "parentId" : parentId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    console.log(response);
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
            this.hideSpinnerUploader(component);
        });
        $A.enqueueAction(a);
    },
    getTitleMedia: function (component, courseId, helper) {
        this.showSpinnerUploader(component);
        var a = component.get("c.getMedia");
        a.setParams({"courseId" : courseId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.course", response);
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
            this.hideSpinnerUploader(component);
        });
        $A.enqueueAction(a);
        window.setTimeout(
            $A.getCallback(function() {
                console.log(component.isValid());
            }), 100
        );
    },
    saveMedia: function (component, helper) {
        this.showSpinnerUploader(component);
        var parentRecordId = component.get("v.recordId");
        var a = component.get("c.updateMedia");
        this.removeCSS(component, "modalBoxUpdateDetails", "slds-fade-in-open");
        this.removeCSS(component, "BackgroundModalBox", "slds-backdrop--open");
        a.setParams({"course" : component.get("v.course")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                        if(parentRecordId.length > 1){
                            if(window.location.href.indexOf('native/bridge') > 0){
                                $A.get('e.force:refreshView').fire();
                            }else{
                                window.location.reload();
                            }
                        } else {
                            var url = window.location.href;
                            if(url.indexOf("/s/") != -1){
                                window.location.href = component.get("v.prefix") + "/s/course/" + component.get("v.course").Id;
                            } else {
                                window.location.href = "/" + component.get("v.course").Id;
                            }
                        }
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
            this.hideSpinnerUploader(component);
        });
        $A.enqueueAction(a);
    },
    applyCSS: function(component, elementId, className) {
        var element = component.find(elementId);
        $A.util.addClass(element, className);
    },
    removeCSS: function(component, elementId, className) {
        var element = component.find(elementId);
        $A.util.removeClass(element, className);
    },
    showSpinnerUploader : function (component) {
        var spinner = component.find('spinnerUpload');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    hideSpinnerUploader : function (component) {
        var spinner = component.find('spinnerUpload');
        $A.util.addClass(spinner, 'slds-hide');
    },
})