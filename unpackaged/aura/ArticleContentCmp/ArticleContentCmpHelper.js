({
	setArticleDetails : function(component) {
		this.showSpinnerAllMedia(component);
		var action = component.get("c.getArticleDetails");
		var currentUrl = window.location.href;
		action.setParams({"articleIdString" : component.get("v.recordId"), "currentUrl" : currentUrl});

		action.setCallback(this, function(a){
			var state = a.getState();
			if (a.getState() === "SUCCESS") {
				var result = a.getReturnValue();
				if (result !== null) {
					component.set("v.articleDetails",result);
					var articleDetailDiv = component.find("articleDetailDiv");
					$A.util.removeClass(articleDetailDiv, "slds-hide");
				}else{
					console.log(component.get("v.recordId")+ ' is not a valid article Id or is not a current published article.');
				}
			}  else if (a.getState() === "ERROR") {
				console.log(a.getError()[0].message);
			}
			this.hideSpinnerAllMedia(component);

		});
		$A.enqueueAction(action);
	},
	voteUp : function(component) {
		var action = component.get("c.voteArticleUpByCurrentUserById");
		action.setParams({ "articleId" : component.get("v.recordId"), "isUp" : true});
		action.setCallback(this, function(a){
			var state = a.getState();
			if (state === "SUCCESS") {
				var articleDetails = component.get("v.articleDetails");
				articleDetails.voteType = 'Up';
				component.set("v.articleDetails", articleDetails);
			} else if (state === "ERROR") {
				console.log(a.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
	voteDown : function(component) {
		var action = component.get("c.voteArticleUpByCurrentUserById");
		action.setParams({ "articleId" : component.get("v.recordId"), "isUp" : false});
		action.setCallback(this, function(a){
			var state = a.getState();
			if (state === "SUCCESS") {
				var articleDetails = component.get("v.articleDetails");
				articleDetails.voteType = 'Down';
				component.set("v.articleDetails", articleDetails);
			} else if (state === "ERROR") {
				console.log(a.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
	setIsGuest : function(component) {
		var action = component.get("c.isGuestUser");
		action.setCallback(this, function(a){
			var state = a.getState();
			if (a.getState() === "SUCCESS") {
				var result = a.getReturnValue();
				component.set("v.isGuest",result);
			} else if (a.getState() === "ERROR") {
				console.log(a.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
	showSpinnerAllMedia : function (component) {
		var spinner = component.find('spinnerArticleDetail');
		$A.util.removeClass(spinner, 'slds-hide');
	},
	hideSpinnerAllMedia : function (component) {
		var spinner = component.find('spinnerArticleDetail');
		$A.util.addClass(spinner, 'slds-hide');
	}
})