({
    launchLearning : function(component, event, helper) {
        var itemId = component.get("v.sectionItemId");
        var tPlanId = component.get("v.trainingPlanId");
        var hideLaunch = component.get("v.hideLaunch");
        if(!hideLaunch){
            var appPlanViewEvent = $A.get("e.redwing:TrainingPlanItemViewEvent");
            appPlanViewEvent.setParams({ "itemId" : itemId, "versionBehavior" : "", "trainingPlanId" : tPlanId }).fire();
        }

    }
})