({
    getVideoDetail : function(component, courseId, _callback) {
        var a = component.get("c.getVideoDetail");
        a.setParams({"courseId" : courseId});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videoDetail", response);
                    if (_callback) {
                        _callback();
                    }
                } else {
                    component.set("v.videoDetail", null);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.videoDetail", null);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setVideos : function(component, searchTerm) {
        console.log(component.get("v.hiddenRecomended"))
        var a = component.get("c.getAllVideos");
        var activeChannel = component.get("v.activeChannelId");
        var activeCatalog = component.get("v.activeCatalogId");
        a.setParams({"searchTerm" : searchTerm, "channelId" : activeChannel, "catalogId" : activeCatalog});
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.videos", response);
                } else {
                    component.set("v.videos", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.videos", []);
                $A.log(action.getState());
            }
		});
        $A.enqueueAction(a);

        if(component.get("v.showRecommended")){
            var maxsizeRecommended = component.get("v.maxCountRecommendedVideos");
            var r = component.get("c.getRecomendedVideos");
            r.setParams({"searchTerm" : searchTerm, "maxCount" : maxsizeRecommended});
            r.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response){
                        component.set("v.recomendedVideos", response);
                    } else {
                        component.set("v.recomendedVideos", []);
                        $A.log('Invalid response');
                    }
                } else {
                    component.set("v.recomendedVideos", []);
                    $A.log(action.getState());
                }
            });
            $A.enqueueAction(r);
        }
    },
    setChannels : function(component) {
        var a = component.get("c.getChannels");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if (response){
                    component.set("v.channel", response);
                    if(response.length == 0){
                        component.set("v.isChannelListEmpty", true);
                    } else {
                        component.set("v.isChannelListEmpty", false);
                    }
                } else {
                    component.set("v.channel", []);
                    $A.log('Invalid response');
                }
            } else {
                component.set("v.channel", []);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },
    setShowPin : function(component) {
        var a = component.get("c.getPinAccess");
        var isShowPin = component.get("v.showPin");
        a.setCallback(this, function(action) {
            if (component.isValid() && action.getState() === "SUCCESS") {
                var response = action.getReturnValue();
                if(response && isShowPin){
                	component.set("v.showPin", true);
                } else {
                    component.set("v.showPin", false);
                }
            } else {
                component.set("v.showPin", false);
                $A.log(action.getState());
            }
        });
        $A.enqueueAction(a);
    },/*
    setFrameSize : function(frm) {
        var parEl = document.getElementById('videoContainer').parentElement;
        var popupEl = parEl.parentElement;

        var frameHeight = popupEl.clientHeight - 220 - 32;
        frm.height = frameHeight + 'px';
        frm.style.height = (frameHeight - 32) + 'px';
    },*/
    parseQueryString : function() {
        var qd = {};
        //Parse URI string
        if (location.href.split("#")[1]) {
            location.href.split("#")[1].split("&").forEach(function(item) {
                var s = item.split("="),
                    k = s[0],
                    v = s[1] && decodeURIComponent(s[1]);
                (k in qd) ? qd[k].push(v) : qd[k] = [v]
            });
        }
        return qd;
    }
})