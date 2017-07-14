({
    applyCSS: function(component, elementId, className) {
        var element = component.find(elementId);
        $A.util.addClass(element, className);
    },
    removeCSS: function(component, elementId, className) {
        var element = component.find(elementId);
        $A.util.removeClass(element, className);
    }
})