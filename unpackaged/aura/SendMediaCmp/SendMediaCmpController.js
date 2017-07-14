({
    doInit: function(component, event, helper) {
        component.set("v.isCommunity", $A.getContext().getApp().indexOf('siteforce:') != -1);
        helper.setTemplateList(component);
        helper.setMediaList(component);
        helper.setSiteList(component);
    },

    quillInit: function(component, event, helper) {
        quill = new Quill('#editor', {
            modules: {
                toolbar: '#toolbar' //toolbarOptions
            },
            theme: 'snow'
        });

        var customButton = component.find('ql-linkToMedia').getElement();
        if (customButton) {
            customButton.addEventListener('click', function() {
                $A.util.removeClass(component.find('link_popup'), 'slds-hide');
                window.setTimeout(
                $A.getCallback(function() {
                        console.log(component.isValid());
                    }), 100
                );
            });
        }
        svg4everybody(); // for display svg in IE
    },

    getLink:  function(component, event, helper){
        var popup = component.find('link_popup');
        if (popup) {
            $A.util.addClass(popup, 'slds-hide');
        }

        var mediaLink = component.get("v.mediaLink");
        if (!(typeof quill === "undefined")) {
            var fullText = quill.getText();
            if (fullText) {
                var index = fullText.indexOf('{LinkShownHere}');
                while (index >= 0) {
                    quill.deleteText(index, 15);
                    fullText = quill.getText();
                    index = fullText.indexOf('{LinkShownHere}');
                }
            }

            var range = quill.getSelection(!quill.hasFocus());
            quill.insertText(range.index, '{LinkShownHere}');
        }
    },

    closeGetLink:  function(component, event, helper){
        var popup = component.find('link_popup');

        if (popup) {
            $A.util.addClass(popup, 'slds-hide');
        }
    },

    templateBodyChanged: function(cmp, evt) {
        var bodyTemplateValue = evt.getParam("value");
        if (!(typeof quill === "undefined")) {
            quill.clipboard.dangerouslyPasteHTML(bodyTemplateValue);
        }
    },

    selectTemplate: function(component, event, helper){
        helper.createTemplateBody(component);
    },

    setPublicLink: function(component, event, helper){
        helper.setPublicLink(component);
    },

    removePill: function(component, event, helper){
        if (event && event.target && event.target.getAttribute)
        {
         	var index = event.target.getAttribute('data-id');
            if (index) {
                helper.removeEmailAddress(component, index);
            }
        }
    },

    addNewEmail: function(component, event, helper) {
        var address = component.get("v.toAddresses");
        var newEmail = component.get("v.newEmailAddress");

        if (!newEmail || newEmail == '') {
            helper.showErrorPreviewMessage(component, $A.get("$Label.vtui.Email_Address_Empty"));
        } else if (address.indexOf(newEmail) >= 0 ) {
            helper.showErrorPreviewMessage(component, $A.get("$Label.vtui.Address_Already_Exist"));
        } else if (!helper.validateEmail(newEmail)) {
            helper.showErrorPreviewMessage(component, $A.get("$Label.vtui.Address_Not_Valid_Email"));
        } else {
            address.push(newEmail);
            component.set("v.toAddresses", address);
            component.set("v.newEmailAddress", '');
        }
    },

    hideErrorPreview: function(component, event, helper){
        helper.hideErrorPreviewBox(component);
    },

    goEditTemplate: function(component, event, helper){
        helper.hideErrorBox(component);
        helper.show_modal_container(component, 'editTemplate');
    },

    goShowPreview: function(component, event, helper){
        var editor = component.find("editor").getElement();
        if (editor) {
            component.set("v.templateBody", editor.innerHTML);
        };

        var templateBody = component.get("v.templateBody");
        var selectCmpMedia = component.find("medias");
        var selectedMediaId = selectCmpMedia.get("v.value");
        var selectCmpSite = component.find("sites");
        var selectedSiteId = selectCmpSite.get("v.value");
        component.set("v.erMessage", '');

        if (templateBody && templateBody.indexOf('{LinkShownHere}') < 0) {
            helper.showErrorMessage(component, $A.get("$Label.vtui.Media_Link_Not_Found"));
        } else if (!selectedMediaId) {
            helper.showErrorMessage(component, $A.get("$Label.vtui.Please_Select_Media"));
        } else if (!selectedSiteId) {
            helper.showErrorMessage(component, $A.get("$Label.vtui.Please_Select_Site"));
        } else if (!templateBody || templateBody == '') {
            helper.showErrorMessage(component, $A.get("$Label.vtui.Email_Template_Empty"));
        } else {
            helper.createEmailBody(component);
            helper.show_modal_container(component, 'showPreview');
            helper.hideErrorPreviewBox(component);
        }
    },

    goMailSent: function(component, event, helper){
        var address = component.get("v.toAddresses");
        if (address && address.length && address.length > 0)
        {
            helper.show_modal_container(component, 'mailSent');
            helper.send(component);
        } else {
            helper.showErrorPreviewMessage(component, $A.get("$Label.vtui.No_One_email_Added_To_List"));
        }
    },

    hideMainModal: function(component, event, helper){
		$A.util.removeClass(component.find('editTemplate'), 'hide');
        $A.util.addClass(component.find('editTemplate'), 'show');
        $A.util.removeClass(component.find('mailSent'), 'show');
        $A.util.addClass(component.find('mailSent'), 'hide');
        component.set("v.templateBody", '');
        component.set("v.subject", '');
        var selectCmp = component.find("emailTeplates");
        selectCmp.set("v.value",'0');
        $A.get("e.force:closeQuickAction").fire();
    },

    hideError: function(component, event, helper){
        helper.hideErrorBox(component);
    }

})