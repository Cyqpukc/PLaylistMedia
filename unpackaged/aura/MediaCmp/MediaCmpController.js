({
    doInit : function(component, event, helper) {
        helper.setShowShareButton(component);
        helper.setIsMobile(component);
    },
    showModal : function(component, event, helper) {
        event.preventDefault();
        var linkToVideo = event.target.getAttribute('href');
        if(window.location.href.indexOf('sfdcIFrameHost=hybrid') != -1 || window.location.href.indexOf('sfdcIFrameHost=web') != -1){
            return;
        }
        if (component.get("v.isMobile")) {
            window.open(linkToVideo);
            return;
        }else{
            var cmpEvent = component.getEvent("openVideoModalEvent");
            cmpEvent.setParams({
                "showPopup" : true,
                "mediaId" : linkToVideo
            });
            cmpEvent.fire();
        }
    },
    showSendForm : function(component, event, helper) {
        if(component.get("v.shareButtonStyle") && component.get("v.shareButtonStyle").toLowerCase() === 'iframe'){
            var backgroundLinkModal = component.find('BackgroundLinkModal').getElement();
            var linkModal = component.find('LinkModal').getElement();
            var modal = component.find('LinkModal');
            if(!linkModal.classList.contains("slds-fade-in-open")){
                var courseId = event.target.getAttribute('data-form-id');
                helper.getMediaLink(component, courseId);
            }
            $A.util.toggleClass(backgroundLinkModal, "slds-backdrop--open");
            $A.util.toggleClass(linkModal, "slds-fade-in-open");
            return;
        } else if(component.get("v.shareButtonStyle") && component.get("v.shareButtonStyle").toLowerCase() === 'link'){
            var backgroundLinkModal = component.find('BackgroundLinkModal').getElement();
            var linkModal = component.find('LinkModal').getElement();
            var modal = component.find('LinkModal');
            if(!linkModal.classList.contains("slds-fade-in-open")){
                var courseId = event.target.getAttribute('data-form-id');
                helper.getPublicLink(component, courseId, component.get("v.siteId"));
            } else{
                component.set("v.publicLink", '');
            }
            $A.util.toggleClass(backgroundLinkModal, "slds-backdrop--open");
            $A.util.toggleClass(linkModal, "slds-fade-in-open");
            return;
        }
        var sendForm;
        if(event.target.getAttribute('data-sendForm-id')){
            sendForm = event.target.parentElement.parentElement.parentElement.children[3];
        } else{
            sendForm = event.target.parentElement.parentElement.children[1].children[0];
        }
        $A.util.addClass(sendForm, "show");
    },
    deleteMedia : function(component, event, helper) {
        var courseId = event.target.getAttribute('data-form-id');
        helper.deleteMedia(component, courseId);
    },
    shareEnter : function(component, event, helper){
        if (event.keyCode == 13) {
            event.target.parentElement.children[1].click();
        } else {
            return;
        }
    },
    shareContents : function(component, event, helper) {
        var recordId;
        var successMessage;
        if(event.target.getAttribute('data-sendForm-id')){
            recordId = event.target.getAttribute('data-sendForm-id')
            successMessage = event.target.parentElement.parentElement.children[4];
        } else{
            recordId = event.target.getAttribute('data-form-id')
            successMessage = event.target.parentElement.parentElement.children[1];
        }
        var emailField = event.target.parentElement.children[0];
        var emailsSplit = emailField.value.split(',');
        var showError;
        if (!helper.validateEmail(emailsSplit[0])) {
            var tmpEmail = emailField.value;
            emailField.style.color = 'red';
            emailField.style.fontSize = '0.9em';

            emailField.value = $A.get("$Label.vtui.Incorrect_Email");
            showError = true;
            setTimeout(
                $A.getCallback(function(){
                    if (showError) {
                        emailField.style.color = '';
                        emailField.value = tmpEmail;
                        showError = false;
                    }
                }), 1500
            );
        } else {
            var a;
            /*if (window.location.href.indexOf('one.app') == -1){
                a = component.get("c.shareCourseInCommunity");
                a.setParams({"contentId" : recordId, "emailTo" : emailsSplit[0], "domain": 'https://'+location.hostname + location.pathname, "autoplay" : "autoplay=0"});
            } else{*/
                a = component.get("c.shareContent");
                a.setParams({"contentId" : recordId, "emailTo" : emailsSplit[0]});
            //}
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response) {
                        emailField.value = "";
                        $A.util.removeClass(event.target.parentElement, 'show');
                        $A.util.addClass(successMessage , 'show');
                        setTimeout($A.getCallback(function(){
                            $A.util.removeClass(successMessage, 'show');
                        }), 2000);
                    } else {
                        var templateMessage = $A.get("$Label.vtui.Error_Send_Email");
                        emailField.value = templateMessage.replace('{email}', emailsSplit[0]);
                        $A.log('Invalid response');
                    }
                } else {
                    $A.log(action.getState());
                }
            });
            $A.enqueueAction(a);
        }
    },
    hiddeSendFormCancel : function(component, event, helper) {
        var emailField = event.target.parentElement.children[0];
        emailField.value = '';
        $A.util.removeClass(event.target.parentElement, 'show');
    },
    attachModalHandler : function (component, event, helper) {
        var courseId = event.target.getAttribute('data-modal-id');
        var cmpEvent = component.getEvent("getVideoDetailEvent");
        cmpEvent.setParams({
            "mediaId" : courseId,
            "showPopup" : true,
            "modalId" : 'theAttachModal'
        });
        cmpEvent.fire();
    },
    removeModalHandler : function (component, event, helper) {
        var courseId = event.target.getAttribute('data-record-id');
        var cmpEvent = component.getEvent("getVideoDetailEvent");
        cmpEvent.setParams({
            "mediaId" : courseId,
            "showPopup" : true,
            "modalId" : 'theRemoveModal'
        });
        cmpEvent.fire();
        var cmpEvent = component.getEvent("setChannelsEvent");
        cmpEvent.fire();
    },
    descriptionModal : function(component, event, helper){
		var modal = component.find("DiscriptionModal");
		if(!$A.util.hasClass(modal, "slds-fade-in-open")){
			var videos = component.get("v.mediaItems");
			var currentVideo = videos[event.target.getAttribute('data-index')];
			component.set("v.videoDetail", currentVideo);
            $A.util.addClass(modal, "slds-fade-in-open")
            helper.showPopupBackground(component, true);
        } else {
            $A.util.removeClass(modal, "slds-fade-in-open")
            helper.showPopupBackground(component, false);
		}
	},
    goToURL : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var link = selectedItem.dataset.record; // Get its binding value
        // Fire the event to navigate to the topic
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