({
    afterRender : function(cmp, helper) {
        var cmpFrame = helper.getComponentFrame(cmp);

        //This fix for fullscreen allowing on community pages. By default, SF remove this attributes.
        cmpFrame.setAttribute("allowfullscreen", "true");
        cmpFrame.setAttribute("mozallowfullscreen", "true");
        cmpFrame.setAttribute("msallowfullscreen", "true");
        cmpFrame.setAttribute("oallowfullscreen", "true");
        cmpFrame.setAttribute("webkitallowfullscreen", "true");

        if(cmp.get("v.disableHeightResize") === false){
            //Ensure - we in Napili community. I can't find better solution for now.
            if (cmp.get("v.enableFixedCommunityHeader") === true && window.document.querySelectorAll(".siteforceNapiliBody").length > 0) {
                var headerDiv = window.document.querySelector("#header");
                var setAutoHeight = function() {
                    cmpFrame.height = '';
                    cmpFrame.height = (helper.getWindowSizes().y - headerDiv.clientHeight - 3) + 'px';
                    window.scrollTo(0, 0);
                }
                setAutoHeight();
                window.onresize = function(){
                    setAutoHeight();
                };
            } else {
                var setHeightByContent = function(){
                    // NOTE: Added this timeout to fix an issue with invalid scrollHeights in communities
                    // This caused the video player to have a very large height
                    setTimeout(function(){
                        if(cmpFrame && cmpFrame.contentWindow && cmpFrame.contentWindow.document){
                            cmpFrame.height = '';
                            cmpFrame.height = (cmpFrame.contentWindow.document.body.scrollHeight + 3) + 'px';
                            window.scrollTo(0, 0);
                        }
                    }, 0);
                }
                if (cmpFrame.addEventListener) {
                    cmpFrame.addEventListener('load', setHeightByContent, true);
                } else if (cmpFrame.attachEvent) {
                    cmpFrame.attachEvent('onload', setHeightByContent);
                }
            }
        }
    }
})