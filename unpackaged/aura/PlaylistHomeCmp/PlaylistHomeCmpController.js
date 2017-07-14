({
	doInit : function(component, event, helper) {
		helper.setCatalogs(component, '');

        var courseId = '';
        var matchCourse = /[&#]Id(=([^&#]*)|&|#|$)/.exec(location.href);
        if (matchCourse != null && matchCourse.length > 2) {
            courseId = matchCourse[2];
        }

        if (courseId != '' && courseId.length <= 18) {
            var a = component.get("c.getLink");
            a.setParams({"courseId" : courseId});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response && response != '') {
                        helper.createMediaPopupCmp(
                            component,
                            response+'&autoplay=0'
                        );
                        component.set("v.showCatalogs", true);
                    } else {
                        $A.log('Invalid response');
                    }
                }
            });
            $A.enqueueAction(a);
        }
	},
    toCatalog : function(component, event, helper) {
        helper.createAllMediaCmp(
            component,
            event.target.parentElement.parentElement.dataset.catalog,
            event.target.parentElement.parentElement.dataset.catalogName,
            "All",
            "All"
        );
        component.set("v.showCatalogs", false);
        component.set("v.showAllVideosCmp", true);
    },
    reloadPage : function(component, event, helper){
        component.set("v.showCatalogs", true);
        component.set("v.showAllVideosCmp", false);
    }
})