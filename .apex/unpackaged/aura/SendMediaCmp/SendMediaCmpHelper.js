({
    setTemplateList : function(component) {
        var a = component.get("c.getTemplates");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.emailTemplates", response);
                } else {
                    component.set("v.emailTemplates", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.videos", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    setMediaList : function(component) {
        var a = component.get("c.getMedias");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.medias", response);
                } else {
                    component.set("v.medias", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.medias", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    setSiteList : function(component) {
        var a = component.get("c.getSites");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.sites", response);
                } else {
                    component.set("v.sites", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.sites", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    createTemplateBody : function(component) {
        var a = component.get("c.getTemplateBody");
        var selectCmp = component.find("emailTeplates");
        var selectedTemplateId = selectCmp.get("v.value");
        a.setParams({"selectedTemplateId" : selectedTemplateId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    var newTemplate = response.HtmlValue;
                    var defaultTemplate = component.get("v.previewBodyOriginal");
                    var oldTemplate = component.get("v.templateBody");
                    component.set("v.templateBody", newTemplate);
                    component.set("v.previewBodyOriginal", newTemplate);
                    component.set("v.subject", response.Subject);
                } else {
                    component.set("v.templateBody", "{LinkShownHere}");
                    component.set("v.subject", "");
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.templateBody", '{LinkShownHere}');
                component.set("v.subject", "");
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    setPublicLink : function(component) {
        var previewButton = component.find("previewButton");
        previewButton.set("v.disabled", true);
        var linkButtonInsert = component.find("linkButtonInsert");
        linkButtonInsert.set("v.disabled", true);
        var a = component.get("c.getPublicLink");
        var selectCmpMedia = component.find("medias");
        var selectCmpSite = component.find("sites");
        var selectedMediaId = selectCmpMedia.get("v.value");
        var selectedSiteId = selectCmpSite.get("v.value");
        var parentId = component.get("v.recordId");
        a.setParams({"mediaId" : selectedMediaId, "siteId" : selectedSiteId, "parentId" : parentId});
        a.setCallback(this, function(action) {

            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response && response.indexOf('http') >= 0){
                    previewButton.set("v.disabled", false);
                    linkButtonInsert.set("v.disabled", false);
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

    createEmailBody : function(component) {
        var a = component.get("c.setEmailBody");
        var mediaLink = component.get("v.mediaLink");
        var parentId = component.get("v.recordId");
        var subject = component.get("v.subject");
        var templateBody = component.get("v.templateBody");
        var imgHeight = component.get("v.imHeight");
        var selectCmpMedia = component.find("medias");
        var selectedMediaId = selectCmpMedia.get("v.value");

        a.setParams({
            "courseId" : selectedMediaId,
            "mediaLink" : mediaLink,
            "parentId" : parentId,
            "subject" : subject,
            "templateBody" : templateBody,
            "imageHeight" : imgHeight + ''
        });

        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response && response.Success){
                    component.set("v.previewBody", response.RenderedTemplate);
                    console.log(response.RenderedTemplate);
                    component.set("v.previewSubject", response.RenderedSubject);
                } else {
                    component.set("v.previewBody", '');
                    component.set("v.previewSubject", '');
                    $A.log('Invalid response');
                    this.hideModals(component);
                    $A.util.removeClass(component.find('editTemplate'), 'hide');
                    $A.util.addClass(component.find('editTemplate'), 'show');
                    component.set("v.erMessage", $A.get("$Label.vtui.Wrong_Email_Template"));
                    if (response.ErrorMessages && response.ErrorMessages.length > 0) {
                        component.set("v.erMessage", response.ErrorMessages[0]);
                    }
                    $A.util.removeClass(component.find('error-container'), 'slds-hide');
                }
            } else {
                component.set("v.previewBody", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    send : function(component) {
        var a = component.get("c.sendEmail");
        var previewBody = component.get("v.previewBody");
        var parentId = component.get("v.recordId");
        var toAddresses = component.get("v.toAddresses");
        var previewSubject = component.get("v.previewSubject");
        a.setParams({"previewBody" : previewBody, "parentId" : parentId, "toAddresses" : toAddresses, "subject" : previewSubject});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.previewBody", response);
                } else {
                    component.set("v.previewBody", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.previewBody", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },

    show_modal_container: function (component, attr) {
    	this.hideModals(component);
        $A.util.removeClass(component.find(attr), 'hide');
        $A.util.addClass(component.find(attr), 'show');
	},
    hideModals: function(component){
        $A.util.addClass(component.find("editTemplate"), 'hide');
        $A.util.addClass(component.find("showPreview"), 'hide');
        $A.util.addClass(component.find("mailSent"), 'hide');
    },
    hideErrorBox: function (component) {
        $A.util.addClass(component.find('error-container'), 'slds-hide');
	},

    showErrorMessage: function (component, erMessage) {
        component.set("v.erMessage", erMessage);
        $A.util.removeClass(component.find('error-container'), 'slds-hide');

        setTimeout(
            $A.getCallback(function(){
                if(component.isValid()){
                    $A.util.addClass(component.find('error-container'), 'slds-hide');
                }
            }), 5000
        );
	},

    hideErrorPreviewBox: function (component) {
        $A.util.addClass(component.find('error-container-preview'), 'slds-hide');
	},

    showErrorPreviewMessage: function (component, erMessage) {
        component.set("v.erMessagePreview", erMessage);
        $A.util.removeClass(component.find('error-container-preview'), 'slds-hide');

        setTimeout(
            $A.getCallback(function(){
                if(component.isValid()){
                    $A.util.addClass(component.find('error-container-preview'), 'slds-hide');
                }
            }), 5000
        );
	},

    removeEmailAddress: function (component, index) {
        var address = component.get("v.toAddresses");
        address.splice(index, 1);
        component.set("v.toAddresses", address);
	},

    validateEmail: function (email) {
        var re = /([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})/;
        return re.test(email);
    }

})