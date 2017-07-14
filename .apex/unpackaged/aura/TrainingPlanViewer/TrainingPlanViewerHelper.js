({

    getTrainingPlanId : function(component){
        return component.get("v.trainingPlanId");
    },

    loadResources : function(component){
        var ldsResources = component.get("v.ldsResource");
        var a = component.get("c.getLMSNamespace");
        a.setCallback(this, function(action) {
            if (action.getState() === "SUCCESS") {
                var lmsNamespace = action.getReturnValue();
                if(lmsNamespace){
                    component.set("v.lmsNamespace", lmsNamespace);
                    var ldsResource = ldsResources[0];
                    ldsResources[0] = ldsResource.replace('/resource/','/resource/'+lmsNamespace+'__');
                    $A.createComponent(
                        "ltng:require",
                        {
                            "styles": ldsResources,
                        },
                        function(ltnReq){
                            if (component.isValid()) {
                                var divComponent = component.find("ltnReq");
                                divComponent.set("v.body", ltnReq);
                            }
                        }
                    );
                }else{
                    $A.createComponent(
                        "ltng:require",
                        {
                            "styles": ldsResources,
                        }, function(ltnReq){
                            if (component.isValid()) {
                                var divComponent = component.find("ltnReq");
                                divComponent.set("v.body", ltnReq);
                            }
                        }
                    );
                }
            }else{
                $A.log(action.getState());
            }

            //Fire the load event after loading resources
            var trainingPlanId = component.get("v.trainingPlanId");
            var appPlanViewEvent = $A.get("e.redwing:TrainingPlanViewEvent");
            appPlanViewEvent.setParams({ "id" : trainingPlanId}).fire();

        });
        $A.enqueueAction(a);
    },

    loadTrainingPlanInfo : function(component, trainingPlanId, autoRegister){
        //Request new data
        this.showSpinner(component);
        var a = component.get("c.loadTrainingPlan");
        a.setParams({
            "trainingPlanId" : trainingPlanId,
            "autoRegister" : autoRegister
        });
        a.setCallback(component, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && response.planAssignment){
                    //Clear existing launchers
                    var launchersComponent = component.find('learningLaunchers');
                    if(launchersComponent){
                        launchersComponent.set("v.body", []);
                    }
                    //Create new launcher components
                    var packageNS = response.lmsNamespace?response.lmsNamespace:'';
                    var communityName = response.communityName;
                    component.set("v.progress", response.planAssignment[packageNS+'Progress_Percentage__c']);
                    //Inspect plan section items info
                    var tPlanSections = response.sections;
                    if(tPlanSections && tPlanSections.length > 0){
                        for (var i = 0; i < tPlanSections.length; i++) {
                            var tPlanSection = tPlanSections[i];
                            if(tPlanSection && tPlanSection.items.length > 0){
                                for (var j = 0; j < tPlanSection.items.length; j++) {

                                    var tPlanSectionItem = tPlanSection.items[j];

                                    //Ignore items without assignments
                                    if(!tPlanSectionItem.latestAssignment){
                                        continue;
                                    }

                                    var recordTypeNS = tPlanSectionItem.learning.RecordType.NamespacePrefix;
                                    var launcherLearningName = tPlanSectionItem.learning.RecordType.DeveloperName;
                                    var componentNS = recordTypeNS;
                                    //Handle plugin record types
                                    if(tPlanSectionItem.isLearningPlugin){
                                        if(tPlanSectionItem.hasCustomLauncher){
                                            componentNS = recordTypeNS;
                                        }else{
                                            componentNS = component.get("v.lmsNamespace");
                                            launcherLearningName = 'Generic';
                                        }
                                    }
                                    var ltngComponentNS = componentNS?componentNS:'c';
                                    var componentType = ltngComponentNS+":"+launcherLearningName+"Launcher";
                                    //Create launcher components
                                    $A.createComponent(
                                        componentType,
                                        {
                                            "aura:id": tPlanSectionItem.currentSectionItemId,
                                            "trainingPlanId" : trainingPlanId,
                                            "learningId": tPlanSectionItem.learning.Id,
                                            "sectionItemId": tPlanSectionItem.currentSectionItemId,
                                            "learningName": tPlanSectionItem.learning.Name,
                                            "assignmentId": tPlanSectionItem.latestAssignment.Id,
                                            "progress": tPlanSectionItem.latestAssignment[packageNS+'Progress_Percentage__c'],
                                            "lmsNamespace" : packageNS,
                                            "communityName" : communityName,
                                            "hideLaunch" : tPlanSectionItem.hideLaunch
                                        },
                                        function(learningLauncher){
                                            if (component.isValid()) {
                                                var divComponent = component.find('learningLaunchers');
                                                var divBody = divComponent.get("v.body");
                                                divBody.push(learningLauncher);
                                                divComponent.set("v.body", divBody);
                                            }
                                        }
                                    );
                                }
                            }
                        }
                    }
                }else{
                    $A.log('Unable to fetch training plan info');
                }
            }else{
                component.set("v.showPlaceholder", true);
                $A.log(action.getState());
            }
            var lmsSpinnerEvent = $A.get("e.redwing:LMSSpinnerEvent");
            lmsSpinnerEvent.setParams({ "sourceId" : trainingPlanId, "isVisible" : false}).fire();
        });
        $A.enqueueAction(a);
    },

    loadTrainingPlanItemViewer : function(component, trainingPlanItemId, versionBehavior){
        this.showSpinner(component);
        var trainingPlanId = component.get("v.trainingPlanId");
        var a = component.get("c.launchTrainingPlanItem");
        a.setParams({
            "itemId" : trainingPlanItemId,
            "versionBehavior" : versionBehavior
        });
        a.setCallback(this, function(action) {
            if(component.isValid() && action.getState() === "SUCCESS"){
                var response = action.getReturnValue();
                if(response){
                    var launchURL = response.launchInfo.launchURL+"&ltng=1";
                    $A.createComponent(
                        "redwing:LearningViewer",
                        {
                            "aura:id": response.item.currentSectionItemId,
                            "trainingPlanId": trainingPlanId,
                            "launchURL": launchURL,
                            "launchBehavior": response.launchBehavior,
                            "itemId": response.item.currentSectionItemId,
                            "hasPreRequisite": response.hasPreRequisite
                        },
                        function(learningViewer, status){
                            if (component.isValid()) {
                                var divComponent = component.find("learningViewer");
                                divComponent.set("v.body", learningViewer);
                            }
                        }
                    );
                }else{
                    $A.log('Invalid response for training plan details');
                }
            }else{
                $A.log(action.getState());
            }
            var lmsSpinnerEvent = $A.get("e.redwing:LMSSpinnerEvent");
            lmsSpinnerEvent.setParams({ "sourceId" : trainingPlanId, "isVisible" : false}).fire();
        });
        $A.enqueueAction(a);
    },

    closeLearningViewer : function(component){
        if(component.isValid()){
            var divComponent = component.find("learningViewer");
            divComponent.set("v.body", []);
        }
    },

    showSpinner : function (component) {
        var trainingPlanId = component.get("v.trainingPlanId");
        var lmsSpinnerEvent = $A.get("e.redwing:LMSSpinnerEvent");
        lmsSpinnerEvent.setParams({ "sourceId" : trainingPlanId, "isVisible" : true}).fire();
    }

})