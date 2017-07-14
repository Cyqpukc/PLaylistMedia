({
    // Your renderer method overrides go here
    rerender: function (component, helper) {
        this.superRerender();
        if (!component.get('v.sldsStyle')) {
            var items = component.find('mediaItem');
            if (items) {
                for (var i = 0; i < items.length; i++) {
                    (function (item) {
                        var img = item.getElement().getElementsByClassName('imageSrc')[0];
                        img.onload = function () {
                            if(item.getElement() != null){
                                if (img.width >= img.height) {
                                    item.getElement().className += " landscapeImage";
                                } else if (img.width < img.height) {
                                    item.getElement().className += " portraitImage";
                                }
                            }
                        }
                    })(items[i]);
                }
            }
        }
    },
    render: function(component, helper) {
        var ret = this.superRender();
        // do custom rendering here
        return ret;
    },
    afterRender: function(component, helper) {
        this.superAfterRender();
    },
    unrender: function(component, helper) {
        this.superUnrender();
    },
})