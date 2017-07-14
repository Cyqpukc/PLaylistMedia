({
    closeModalBox: function(component, event, helper) {
        component.set("v.mediaSrc", "");
        window.setTimeout(
           $A.getCallback(function() {
                if (component.isValid()){
                    var videoModal = component.find('VideoPopUp');
                    $A.util.removeClass(videoModal, 'slds-fade-in-open');
                    var spinner = component.find('spinnerPopUp');
                    $A.util.removeClass(spinner, 'slds-hide');
                    component.set("v.showPopup", false);
                    component.set("v.showPopupBackground", false);
                }
            }), 100
        );
    },
    setFrameSize: function(component, event, helper) {
        helper.updateFrameSize(component);
        helper.updateAttributes(component);
        var videoModal = component.find('VideoPopUp');
        if(videoModal){
            var spinner = component.find('spinnerPopUp');
            $A.util.addClass(spinner, 'slds-hide');
            $A.util.addClass(videoModal, 'slds-fade-in-open');
        }
        if(window.attachEvent) {
            window.attachEvent('onresize', function() {
                if (component.isValid()) {
                    helper.updateFrameSize(component);
                }
            });
        }
        else if(window.addEventListener) {
            window.addEventListener('resize', function() {
                if (component.isValid()) {
                    helper.updateFrameSize(component);
                }
            }, true);
        }
    }
})