({
    doInit : function(component, event, helper) {
        helper.loadResources(component);
    },

    handleLoadEvent : function(component, event, helper){
        var trainingPlanId = helper.getTrainingPlanId(component);
        var autoRegister = component.get("v.autoRegister") === true;
        var eventPlanId = event.getParam("id");
        if(trainingPlanId === eventPlanId){
            helper.loadTrainingPlanInfo(component, trainingPlanId, autoRegister);
        }
    },

    handleItemViewEvent : function(component, event, helper){
        var trainingPlanId = helper.getTrainingPlanId(component);
        var eventPlanId = event.getParam("trainingPlanId");
        if(trainingPlanId === eventPlanId){
            var trainingPlanItemId = event.getParam("itemId");
            var versionBehavior = event.getParam("versionBehavior");
            helper.loadTrainingPlanItemViewer(component, trainingPlanItemId, versionBehavior);
        }
    },

    handleLearningViewEvent : function(component, event, helper){
        var trainingPlanId = helper.getTrainingPlanId(component);
        var autoRegister = component.get("v.autoRegister") === true;
        var eventPlanId = event.getParam("trainingPlanId");
        var type = event.getParam("type");
        if(type === "close"){
            helper.closeLearningViewer(component);
        }
        //Refresh launchers progress
        if(eventPlanId && eventPlanId.length === 18 && trainingPlanId.length === 15){
            eventPlanId = eventPlanId.substring(0, 15);
        }
        if(trainingPlanId === eventPlanId){
            helper.loadTrainingPlanInfo(component, trainingPlanId, autoRegister);
        }
    },

    showSystemError: function(component, event){
        $A.log(component);
        $A.log(event);
    }
})