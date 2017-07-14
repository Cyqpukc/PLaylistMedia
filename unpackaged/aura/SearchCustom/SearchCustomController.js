({
	doInit : function(component, event, helper) {
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
                        component.set("v.activeTab", "videos");
                        helper.loadContentActiveTab(component);
                    } else {
                        $A.log('Invalid response');
                    }
                }
            });
            $A.enqueueAction(a);
        } else{
            helper.loadContentActiveTab(component);
        }
	},
    setActive : function(component, event, helper) {
        var clickedTab = helper.getEventElement(event).parentElement.parentElement;
        component.set("v.activeTab", clickedTab.dataset.tab.toString());
        helper.loadContentActiveTab(component);
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
    }
})