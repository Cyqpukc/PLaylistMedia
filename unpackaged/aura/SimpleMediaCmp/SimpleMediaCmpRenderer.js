({
    afterRender: function (component, helper){
        var iframe = component.find("CustomPlayerIframe");
        if(iframe){
            iframe = iframe.getElement();
            iframe.setAttribute("allowfullscreen", "true");
            iframe.setAttribute("mozallowfullscreen", "true");
            iframe.setAttribute("msallowfullscreen", "true");
            iframe.setAttribute("oallowfullscreen", "true");
            iframe.setAttribute("webkitallowfullscreen", "true");
        }
    },
    rerender: function(component, helper){
        var iframe = component.find("CustomPlayerIframe");
        if(iframe){
            iframe = iframe.getElement();
            var curVal = iframe.getAttribute("src");
            if (component.get("v.mediaSrc") != curVal && component.get("v.mediaSrc") != '') {
                iframe.setAttribute("src", component.get("v.mediaSrc"));
            }
        }
    }
})