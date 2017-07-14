({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId){

        } else{
            var str = window.location.href;
            var arr = str.split(':');
            var params = new Array();
            for(var i=0; i < arr.length; i++){
                var temp = arr[i].split('=');
                if(temp[0].length > 0){
                    params[temp[0]] = temp[1];
                }
            }
            console.log(params);
            if('recordId' in params){
                recordId = params['recordId'];
            }
        }
        helper.setMedia(component, recordId);
        var courseId = '';
        var match = /[?&#]Id(=([^&#]*)|&|#|$)/.exec(location.href);
        if (match != null && match.length > 2) {
            courseId = match[2];
        }
        if (courseId != '' && courseId.length <= 18) {
            var a = component.get("c.getLink");
            a.setParams({"courseId" : courseId});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
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
    loadSvgScript : function(component, event, helper) {
        svg4everybody();
    },
    openVideoModalHandler: function(component, event, helper) {
        var mediaLink = event.getParam("mediaId");
        var showPopup = event.getParam("showPopup");
        component.set("v.currentMediaSrc", mediaLink);
        component.set("v.showMediaPopup", showPopup);
        component.set("v.showMediaPopupBackground", showPopup);
    },
    showPopupBackgroundHandler: function(component, event, helper) {
        var showPopup = event.getParam("showPopup");
        component.set("v.showMediaPopupBackground", showPopup);
    }
})