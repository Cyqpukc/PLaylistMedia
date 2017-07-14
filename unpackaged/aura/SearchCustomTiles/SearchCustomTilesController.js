({
	doInit : function(component, event, helper) {
	    helper.loadContentActiveTab(component);
	},
    setActive : function(component, event, helper) {
        var clickedTab = helper.getEventElement(event).parentElement.parentElement;
        component.set("v.activeTab", clickedTab.dataset.tab.toString());
        helper.loadContentActiveTab(component);
    }
})