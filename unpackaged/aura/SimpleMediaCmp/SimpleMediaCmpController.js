({
    doInit : function(component, event, helper) {
        var url = window.location.href;
        if(url.indexOf("commeditor") != -1){
            component.set("v.isShowPlayer", false);
        } else{
            var mediaId = component.get("v.mediaId");
            if( mediaId.length > 0){
                helper.checkCourseId(component);
            } else{
                if(component.get("v.recordId").length > 0){
                    component.set("v.mediaId", component.get("v.recordId"));
                } else{
                    component.set("v.isError", true);
                    component.set("v.isShowPlayer", false);
                }
            }
            helper.getPathPrefix(component);
        }
    },
    showModalBox : function(component, event, helper){
        helper.setClass(component, "backgroundModal", "slds-backdrop--open");
        helper.setClass(component, "modalBox", "slds-fade-in-open");
    },
    setFrameSize : function(component, event, helper) {
        helper.setFrameSize(component);
        if(window.attachEvent) {
            window.attachEvent('onresize', function() {
                if (component.isValid()) {
                    helper.setFrameSize(component);
                }
            });
        }
        else if(window.addEventListener) {
            window.addEventListener('resize', function() {
                if (component.isValid()) {
                    helper.setFrameSize(component);
                }
            }, true);
        }
    },
    showSendForm : function(component, event, helper) {
        if(component.get("v.shareButtonStyle") && component.get("v.shareButtonStyle").toLowerCase() === 'iframe'){
            var backgroundmodalBox = component.find('backgroundModal').getElement();
            var linkModal = component.find('modalBox').getElement();
            var modal = component.find('modalBox');
            if(!linkModal.classList.contains("slds-fade-in-open")){
                helper.getMediaLink(component);
            }
            $A.util.toggleClass(backgroundmodalBox, "slds-backdrop--open");
            $A.util.toggleClass(linkModal, "slds-fade-in-open");
            return;
        } else if(component.get("v.shareButtonStyle") && component.get("v.shareButtonStyle").toLowerCase() === 'link'){
            var backgroundmodalBox = component.find('backgroundModal').getElement();
            var linkModal = component.find('modalBox').getElement();
            var modal = component.find('modalBox');
            if(!linkModal.classList.contains("slds-fade-in-open")){
                helper.getPublicLink(component, component.get("v.siteId"));
            } else{
                component.set("v.publicLink", '');
            }
            $A.util.toggleClass(backgroundmodalBox, "slds-backdrop--open");
            $A.util.toggleClass(linkModal, "slds-fade-in-open");
            return;
        }
        var sendForm = component.find('sendForm');
        $A.util.removeClass(sendForm, "slds-hide");
    },
    shareEnter : function(component, event, helper){
        if (event.keyCode == 13) {
            event.target.parentElement.children[1].click();
        } else {
            return;
        }
    },
    shareContents : function(component, event, helper) {
        var recordId = component.get("v.mediaId");
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
            a = component.get("c.shareContent");
            a.setParams({"contentId" : recordId, "emailTo" : emailsSplit[0]});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response) {
                        emailField.value = "";
                        var sendForm = component.find('sendForm');
                        $A.util.addClass(sendForm, 'slds-hide');
                        var successSendNotification = component.find('successSendNotification');
                        $A.util.removeClass(successSendNotification , 'slds-hide');
                        setTimeout($A.getCallback(function(){
                            $A.util.addClass(successSendNotification, 'slds-hide');
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
        var successSendNotification = component.find('sendForm');
        var emailField = event.target.parentElement.children[0];
        emailField.value = '';
        $A.util.addClass(successSendNotification , 'slds-hide');
    },
})