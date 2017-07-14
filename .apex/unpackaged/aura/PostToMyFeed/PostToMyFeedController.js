({
	showModal : function(component, event, helper) {
        var btn = component.find("postButton");
        if(btn){
            btn.set("v.disabled", false);
        }
        component.set("v.message", '');
        helper.applyCSS(component, "backGroundMyFeedSectionId", "slds-backdrop--open");
        helper.applyCSS(component, "MyFeedSectionId", "slds-fade-in-open");
    },
    showModalBox : function(component, event, helper) {
        helper.removeCSS(component, "backGroundMyFeedSectionId", "slds-backdrop--open");
        helper.removeCSS(component, "MyFeedSectionId", "slds-fade-in-open");
        helper.removeCSS(component, "modalSuccessfully", "slds-fade-in-open");
    },
    postToMyFeed : function(component, event, helper) {
        var btn = component.find("postButton");
        if(btn){
            btn.set("v.disabled", true);
        }
        var messageToChatter = component.get("v.message");
        var action = component.get("c.postToMyFeedCtrl");
        var recordId =  component.get("v.recordId");
        action.setParams({
            courseId: recordId,
            message: messageToChatter
        });
        action.setCallback(this, function(r) {
            var state = r.getState();
            if (state === "SUCCESS") {
                helper.applyCSS(component, "modalSuccessfully", "slds-fade-in-open");
                helper.removeCSS(component, "MyFeedSectionId", "slds-fade-in-open");
            } else if (state === "ERROR") {
                throw new Error("Error : " + r.getError());
            } else {
                throw new Error("Unknown error : ");
            }
        });
		$A.enqueueAction(action);
    }
})