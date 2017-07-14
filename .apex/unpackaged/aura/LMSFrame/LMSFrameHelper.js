({
    getWindowSizes : function() {
        var result = {};
        result.e = document.documentElement;
        result.g = document.getElementsByTagName('body')[0];
        result.x = window.innerWidth || result.e.clientWidth || result.g.clientWidth;
        result.y = window.innerHeight || result.e.clientHeight|| result.g.clientHeight;
        return result;
    },
    getComponentFrame : function(cmp){
        return cmp.getElements().filter(function(element){return element.tagName === "IFRAME";})[0];
    }
})