({
    updateVersion : function(component, event, helper) {
        var itemId = component.get("v.itemId");
        var tPlanId = component.get("v.trainingPlanId");
        var appPlanViewEvent = $A.get("e.redwing:TrainingPlanItemViewEvent");
        appPlanViewEvent.setParams({ "itemId" : itemId, "versionBehavior" : "update_version", "trainingPlanId" : tPlanId }).fire();
    },

    keepOldVersion : function(component, event, helper) {
        var itemId = component.get("v.itemId");
        var tPlanId = component.get("v.trainingPlanId");
        var appPlanViewEvent = $A.get("e.redwing:TrainingPlanItemViewEvent");
        appPlanViewEvent.setParams({ "itemId" : itemId, "versionBehavior" : "keep_old", "trainingPlanId" : tPlanId }).fire();
    },

    closeViewer : function(component, event, helper) {
        var tPlanId = component.get("v.trainingPlanId");
        var appPlanViewEvent = $A.get("e.redwing:LearningViewEvent");
        appPlanViewEvent.setParams({ "type" : "close", "message" : "", "trainingPlanId" : tPlanId}).fire();
    }

})