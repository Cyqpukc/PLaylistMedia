({
	getGroupLst : function(component, event, helper) {
		var action = component.get("c.getMyGroupsList");
		action.setCallback(this, function(a) {
			if (a.getState() === "SUCCESS") {
				component.set("v.groupList", a.getReturnValue());
			} else if (a.getState() === "ERROR") {
				$A.log("Errors", a.getError());
			}
		});
		$A.enqueueAction(action);
	},
	showModal : function(component, event, helper) {
        helper.applyCSS(component, "backGroundGroupsSectionId", "slds-backdrop--open");
        helper.applyCSS(component, "groupsSectionId", "slds-fade-in-open");
        component.set("v.message", '');
        var btn = component.find("postButton");
        if(btn){
            btn.set("v.disabled", false);
        }
    },
    showModalBox : function(component, event, helper) {
        helper.removeCSS(component, "groupsSectionId", "slds-fade-in-open");
        helper.removeCSS(component, "modalSuccessfully", "slds-fade-in-open");
        helper.removeCSS(component, "backGroundGroupsSectionId", "slds-backdrop--open");
    },
    hiddenErrorModalBox : function(component, event, helper) {
        helper.removeCSS(component, "backGroundGroupsId", "slds-backdrop--open");
        helper.removeCSS(component, "modalError", "slds-fade-in-open");
    },
    postHereCtrl : function(component, event, helper) {
		var spinner = component.find('spinnerPostToChatter');
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log(component.find("postTocheckbox"));
        var checkboxes = new Array();
        var checkboxesCpm = component.find("postTocheckbox");
        if(checkboxesCpm.length){
            for(var i=0; i<checkboxesCpm.length; i++){
                checkboxes.push(checkboxesCpm[i].getElement());
            }
        } else{
            checkboxes.push(checkboxesCpm.getElement());
        }
        //console.log(checkboxes);
        var messageToChatter = component.get("v.message");
        var groupIds = new Array();
        for (var i=0; i<checkboxes.length; i++) {
            //console.dir(checkboxes[i]);
            //console.log(checkboxes[i].getAttribute('data-group-id'));
            if(checkboxes[i].checked) {
                groupIds.push(checkboxes[i].getAttribute('data-group-id'));
            }
        }
        if (groupIds.length == 0) {
            console.log('Please select group');
            helper.applyCSS(component, "modalError", "slds-fade-in-open");
            helper.applyCSS(component, "backGroundGroupsId", "slds-backdrop--open");
			var spinner = component.find('spinnerPostToChatter');
	        $A.util.addClass(spinner, 'slds-hide');
            return;
        }
        var btn = component.find("postButton");
        if(btn){
            btn.set("v.disabled", true);
        }
        var idListJSON = JSON.stringify(groupIds);
        var action = component.get("c.postHere");
        action.setParams({
            groupIds: idListJSON,
            courseId: component.get("v.recordId"),
            message: messageToChatter
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                helper.applyCSS(component, "modalSuccessfully", "slds-fade-in-open");
                helper.removeCSS(component, "groupsSectionId", "slds-fade-in-open");
                var checkboxes = new Array();
                var checkboxesCpm = component.find("postTocheckbox");
                if(checkboxesCpm.length){
                    for(var i=0; i<checkboxesCpm.length; i++){
                        checkboxes.push(checkboxesCpm[i].getElement());
                    }
                } else{
                    checkboxes.push(checkboxesCpm.getElement());
                }
                for (var i=0; i<checkboxes.length; i++) {
                    if(checkboxes[i].checked) {
                        checkboxes[i].checked = false;
                    }
                }
				var spinner = component.find('spinnerPostToChatter');
		        $A.util.addClass(spinner, 'slds-hide');
            } else if (a.getState() === "ERROR") {
                console.log('Error');
				var spinner = component.find('spinnerPostToChatter');
		        $A.util.addClass(spinner, 'slds-hide');
				$A.log("Errors", a.getError());
			}
		});
		$A.enqueueAction(action);
    }
})