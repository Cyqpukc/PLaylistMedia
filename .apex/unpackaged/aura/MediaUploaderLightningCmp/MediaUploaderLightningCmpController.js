({
    doInit : function(cmp, event, helper) {
        cmp.set("v.originalDomain", encodeURIComponent(window.location.href));
        helper.getPathPrefix(cmp);
        helper.getDomain(cmp);
        var parentRecordId = cmp.get("v.recordId");
        var isCreateMedia = cmp.get("v.isCreateMediaContent");
        var url = window.location.pathname;
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
        var eventer = window[eventMethod];
        var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
        eventer(messageEvent,function(e) {
            if(e.data){
                var data = JSON.parse(e.data);
                if(data.hasOwnProperty('download')){
                    document.getElementById('uploaderIframe').style.visibility = "visible";
                }
                if(data.hasOwnProperty('result')){
                    if(parentRecordId.length > 1){
                        if(isCreateMedia){
                            helper.createMediaContent(cmp, data.result, parentRecordId);
                        }
                        window.location.reload();
                    } else {
                        window.location.href = cmp.get("v.prefix") + "/s/course/" + data.result;
                    }
                }
            }
        },false);
    }
})