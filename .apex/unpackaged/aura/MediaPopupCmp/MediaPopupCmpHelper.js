({
    updateFrameSize: function(component) {
        var popupEl = component.find('VideoModalContainer').getElement();
        if (popupEl) {
            var frm = component.find('VideoFrame').getElement();
            var frameHeight = popupEl.clientHeight - 220 - 32;
            var frameWidth = frameHeight / 9.0 * 16.0;
            if (window.location.href.indexOf('one.app') > 0) {
                frameHeight = frameHeight - 166;
            }
            frm.setAttribute('style', 'height: ' + (frameHeight - 32) + 'px');
        }
    },
    updateAttributes: function(component) {
        var iframe = component.find("VideoFrame").getElement();
        if(iframe){
            iframe.setAttribute("allowfullscreen", "true");
            iframe.setAttribute("mozallowfullscreen", "true");
            iframe.setAttribute("msallowfullscreen", "true");
            iframe.setAttribute("oallowfullscreen", "true");
            iframe.setAttribute("webkitallowfullscreen", "true");
            var curVal = iframe.getAttribute("src");
            if (component.get("v.mediaSrc") != curVal && component.get("v.mediaSrc") != '') {
                iframe.setAttribute("src", component.get("v.mediaSrc"));
            }
        }
    }
})