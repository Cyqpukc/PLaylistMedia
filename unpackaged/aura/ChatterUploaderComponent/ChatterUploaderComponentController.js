({
    doInit: function(cmp, event, helper) {
        cmp.set("v.uploaderUrl", helper.getFrameUrl(helper.getPrefix(), helper.getSubjectId()));
    },
	showModal : function(component, event, helper) {
		document.getElementById("ChatterCourseUploadBoxBackground").style.display = "block";
		document.getElementById("ChatterCourseUploadBox").style.display = "block";
	},    
	showModalBox : function(component, event, helper) {
		document.getElementById("ChatterCourseUploadBoxBackground").style.display = "none";
		document.getElementById("ChatterCourseUploadBox").style.display = "none";      
        component.set("v.uploaderUrl", "");
        component.set("v.uploaderUrl", helper.getFrameUrl(helper.getPrefix(), helper.getSubjectId()));
	},
 	saveAccount : function(component, event, helper) {
		var action = component.get("c.getAccountupdatedlist");
		action.setParams({ "newAcc" : component.get("v.newAccount")});
		action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                document.getElementById("ChatterCourseUploadBoxBackground").style.display = "none";
                document.getElementById("newAccountSectionId").style.display = "none";
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
		});
 		$A.enqueueAction(action);
	}
})