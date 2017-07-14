({
	doInit : function(component, event, helper) { 
		helper.setArticleDetails(component);
	},
	voteUp : function(component, event, helper) {
		console.log('VOTED UP');
		helper.voteUp(component);
	},
	voteDown : function(component, event, helper) { 
		helper.voteDown(component);
	},
	goToURL : function(component, event, helper) {
		var selectedItem = event.currentTarget; // Get the target object
		var link = selectedItem.dataset.record; // Get its binding value
		// Fire the event to navigate to the topic
		if (link != '') {
			var navEvt = $A.get("e.force:navigateToURL");
			navEvt.setParams({
				"url": link,
				"isredirect": true
			})
			navEvt.fire();
		}
	}
})