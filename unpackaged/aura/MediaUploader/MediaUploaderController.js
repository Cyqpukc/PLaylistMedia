({
    doInit : function(component, event, helper) {
        component.set("v.originalDomain", encodeURIComponent(window.location.href));
        helper.getAccessToUpload(component);
        helper.getPathPrefix(component);
        helper.getDomain(component);
        helper.getSessionId(component);
        var parentRecordId = component.get("v.recordId");
        var isCreateMedia = component.get("v.isCreateMediaContent");
        if(parentRecordId){

        }else{
            var str = window.location.href;
            var arr = str.split(':');
            var params = new Array();
            for(var i=0; i < arr.length; i++){
                var param = arr[i].split('=');
                console.log(param);
                if(param[0].length > 0){
                    params[param[0]] = param[1];
                }
            }
            if('recordId' in params){
                parentRecordId = params['recordId'];
                component.set("v.recordId", params['recordId']);
            }
        }
        var url = window.location.pathname;
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
        var eventer = window[eventMethod];
        var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
        eventer(messageEvent,function(e) {
            if(component.isValid()) {
                if(e.data){
                    var data = JSON.parse(e.data);
                    if(data.hasOwnProperty('onload')){

                    }
                    if(data.hasOwnProperty('upload')){
                        var iframeId = 'uploaderIframe';
                        var cssClassName = 'uploading';
                        if(component.get("v.isUploadSFContent")){
                            iframeId += 'SF';
                            cssClassName = 'uploadingSF';
                            if($A.get("$Browser.formFactor") === 'PHONE'){
                                cssClassName = 'uploadingSFMobile';
                            }
                        }
                        var iFrm = component.find(iframeId);
                        iFrm.getElement().classList.toggle(cssClassName);
                        //$A.util.toggleClass(iFrm, cssClassName);
                        window.setTimeout(
                            $A.getCallback(function() {
                                console.log(component.isValid());
                            }), 100
                        );
                    }
                    if(data.hasOwnProperty('uploadSuccessful')){
                        var iframeId = 'uploaderIframeSF';
                        var cssClassName = 'uploadSFMobile';
                        var iFrm = component.find(iframeId);
                        iFrm.getElement().classList.toggle(cssClassName);
                        iFrm.getElement().classList.remove('uploadingSFMobile');
                        iFrm.getElement().classList.remove('uploadingSF');
                        //$A.util.toggleClass(iFrm, cssClassName);
                        //$A.util.removeClass(iFrm, 'uploadingSFMobile');
                        //$A.util.removeClass(iFrm, 'uploadingSF');
                        window.setTimeout(
                            $A.getCallback(function() {
                                console.log(component.isValid());
                            }), 100
                        );
                    }
                    if(data.hasOwnProperty('result')){
                        helper.applyCSS(component, "modalBoxUpdateDetails", "slds-fade-in-open");
                        helper.applyCSS(component, "BackgroundModalBox", "slds-backdrop--open");
                        if(window.location.href.indexOf('sfdcIFrameHost=hybrid') != -1){
                            var popUpDetail = component.find('uploadModalContainer');
                            if(popUpDetail){
                                $A.util.addClass(popUpDetail, 'popupForSF1');
                                popUpDetail.getElement().classList.add('popupForSF1');
                            }
                        }
                        if(parentRecordId.length > 1){
                            if(isCreateMedia){
                                helper.createMediaContent(component, data.result, parentRecordId);
                            }
                        }
                        helper.getTitleMedia(component, data.result, helper);
                        component.set("v.isCreateMediaContent", isCreateMedia);
                    }
                }
            }
        },false);
        component.set(
            "v.uploaderIframeSrc",
            'https://' + component.get("v.domain") + component.get("v.prefix")
                + '/apex/vtui__mediauploaderSF?originalDomain='+component.get("v.originalDomain")
        );
    },
    hiddenModalBox : function(component, event, helper) {
        if(component.get("v.course").Name.trim()){
            helper.saveMedia(component, helper);
        }
    },
    hiddenErrorModalBox : function(cmp, event, helper) {
        var ifrm = component.find("uploaderIframe").getElement();
        component.set("v.uploaderIframeSrc", "");
        cmp.set("v.showErrorModal", false);
        component.set(
            "v.uploaderIframeSrc",
            'https://' + cmp.get("v.domain") + cmp.get("v.prefix") + '/apex/vtui__mediauploaderSF?originalDomain='+cmp.get("v.originalDomain")
        );
    }
})