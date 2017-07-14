({
	getSessionId: function (component) {
        var a = component.get("c.getSessionId");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.sessionId", response);
                } else {
                    component.set("v.sessionId", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.sessionId", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    convertFile: function (component, docId) {
        var a = component.get("c.convertToMedia");
        a.setParams({"docId" : docId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.courseId", response);
                } else {
                    component.set("v.courseId", '');
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.courseId", '');
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
        document.getElementById('message').click();
    },
    getTitleMedia: function (component, courseId) {
        var a = component.get("c.getMedia");
        console.log('courseId');
        console.log(courseId);
        a.setParams({"courseId" : courseId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                console.log('--');
                console.log(response);
                console.log('---');
                if (response){
                    component.set("v.isShowUploader", false);
                    component.set("v.course", response);
                    
                    docId = response.scormanywhere__SCORM_Training_Path__c.replace('sfdclocal://','');
                    var urlToVideo = 'https://' + location.hostname + '/sfc/servlet.shepherd/version/download/' + docId;
                    console.log(urlToVideo);
	                var videoHelper = document.getElementById('videoHelper');
                    videoHelper.addEventListener('loadedmetadata', function() {
                        console.log(videoHelper.duration);
                        $A.run(function(){
                            var b = component.get('c.setDuration');
                            b.setParams({"course" : response, "docId" : docId, "duration" : "" + videoHelper.duration});
                            b.setCallback(this, function(act){
                                if (component.isValid() && act.getState() === "SUCCESS") {
                                    var resp = action.getReturnValue();
                                    if (resp) {
                                        console.log("Set Duration -> " + resp);
                                    } else {
                                        console.log('Invalid response');
                                    }
                                } else {
                                    console.log(act.getState());
                                }
                            });
                            $A.enqueueAction(b);
                            
                            //videoHelper.currentTime = 5;
                            videoHelper.oncanplay = function() {
                            	var canvas = document.getElementById("thumbHelper");
                                var context = canvas.getContext('2d');
                                canvas.width = 320;
                                canvas.height = 240;
                                context.fillRect(0, 0, 320, 240);
                                context.drawImage(videoHelper, 0, 0, 320, 240);
                                var fileName = (Math.random() * 1000).toString().replace('.', '') + '.png';

                                canvas.toBlob(function(blob) {
                                    var client = new forcetk.Client();
                                    client.setSessionToken(component.get('v.sessionId'));
                                    client.instanceUrl = 'https://teamprfcnt-americanexpressgcppartners.cs3.force.com';
                                    client.proxyUrl = null;
                                    client.visualforce = false;
                                    client.createBlob('ContentVersion', {
                                        Origin: 'C', // 'H' for Chatter File, 'C' for Content Document
                                        PathOnClient: fileName
                                    }, fileName, 'VersionData', blob, function(response){
                                        console.log(response);
                                        console.log("SUCCESS, response.id: " + response.id);
                                        console.log('https://' + location.hostname + '/sfc/servlet.shepherd/version/download/' + response.id);
                                        component.set("v.course.scormanywhere__Thumbnail_Path__c", '/sfc/servlet.shepherd/version/download/' + response.id);
                                    }, function(request, status, response){
                                        console.log(response);
                                        console.log("Error: " + status);
                                    }, "image/png");
                                });
                            };
                        });
                    });
                    videoHelper.setAttribute("src", urlToVideo);
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    saveMedia: function (component) {
        var a = component.get("c.updateMedia");
        a.setParams({"course" : component.get("v.course")});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    window.location.reload();
                } else {
                    $A.log('Invalid response');
                }
            } else {
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    }
})