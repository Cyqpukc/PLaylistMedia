({
	doInit : function(component, event, helper) {
    	var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.href, true);
        /*xhr.upload.onprogress = function (event) {
            console.log(event);
        };*/
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                console.log(['testXHR', xhr.status]);
            }
        }
        var formData = new FormData();
        formData.append('file', 'xxxx');
        formData.append('files', new Blob(['testblob'], {type : 'application/json'}), 'testblob');
        
        xhr.send(new Blob(['testblob'], {type : 'application/json'}));
	}
})