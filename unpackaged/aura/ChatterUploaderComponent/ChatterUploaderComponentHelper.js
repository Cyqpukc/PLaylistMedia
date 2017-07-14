({
    getComponentFrame : function(cmp){
        return cmp.getElements().filter(function(element){return element.tagName == "IFRAME"})[0];
    },
	getPrefix : function() {
		var result;
        var match = /https{0,1}:\/\/[^\/]+\/([^\/]+)\/s\/.*$/.exec(window.location.href);
        if (match != null && match.length > 1) {
            result = match[1];
        }
        return result;
	},
    getSubjectId : function() {
        var match = /\/(group|profile)\/([a-zA-Z\d]+)/.exec(window.location.href);
        if (match != null && match.length > 2) {
            return match[2];
        }
    },
    getFrameUrl : function(prefix, groupId) {
        var uploaderUrl = ((prefix) ? "/" + prefix + "/" : "/");
        uploaderUrl += "apex/CommunityChatterUploader";
        uploaderUrl += "?redirectURL=" + encodeURIComponent(window.location.href);
        if (groupId) {
            uploaderUrl += "&groupId=" + encodeURIComponent(groupId);
        }
        return uploaderUrl;
    }
})