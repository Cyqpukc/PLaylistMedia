({
	doInit : function(component, event, helper) {
        helper.getSessionId(component);
    },
    initUploader : function(component, event, helper) {
        console.log([forcetk.Client]);
        forcetk.Client.prototype.blob = function (path, fields, filename, payloadField, payload, callback, error, retry) {
           'use strict';            
            path =  '/v35.0/chatter/feed-elements/batch';
fields = {
               "inputs": [{
               		"binaryPartNames": [
                    	"VersionData"
                    ],
		"richInput": {

        "subjectId": "me",

        "body": {

          "messageSegments": [

            {

              "type": "Text",

              "text": "Please accept this receipt"

            }

          ]

        },

        "capabilities": {

          "content": {

            "description": "Receipt for expenses",

            "title": filename

          }

        },

        "feedElementType": "FeedItem"

      }

                }]  
           };

            var randomString = function () {
                'use strict';
                var str = '',
                    i;
                for (i = 0; i < 4; i += 1) {
                    str += (Math.random().toString(16) + "000000000").substr(2, 8);
                }
                return str;
            };
           	var that = this,
               url = (this.visualforce ? '' : this.instanceUrl) + '/autumn/services/data' + path,
               boundary = randomString(),
               blob = new Blob([
                   "--boundary_" + boundary + '\n'
                   + "Content-Disposition: form-data; name=\"entity_content\";" + "\n"
                   + "Content-Type: application/json" + "\n\n"
                   + JSON.stringify(fields)
                   + "\n\n"
                   + "--boundary_" + boundary + "\n"
                   + "Content-Type: application/octet-stream" + "\n"
                   + "Content-Disposition: form-data; name=\"" + payloadField
                   + "\"; filename=\"" + filename + "\"\n\n",
                   payload,
                   "\n\n"
                   + "--boundary_" + boundary + "--"
               ], {type : 'multipart/form-data; boundary=\"boundary_' + boundary + '\"'}),
               request = new XMLHttpRequest();

           request.open("POST", (this.proxyUrl !== null && !this.visualforce) ? this.proxyUrl : url, this.asyncAjax);
           request.setRequestHeader('Accept', 'application/json');
           request.setRequestHeader('Content-Encoding', 'gzip');
           request.setRequestHeader(this.authzHeader, "Bearer " + this.sessionId);
           request.setRequestHeader('X-User-Agent', 'salesforce-toolkit-rest-javascript/' + this.apiVersion);
           request.setRequestHeader('Content-Type', 'multipart/form-data; boundary=\"boundary_' + boundary + '\"');
           if (this.proxyUrl !== null && !this.visualforce) {
               request.setRequestHeader('SalesforceProxy-Endpoint', url);
           }
           if (this.asyncAjax) {
               request.onreadystatechange = function () {
                   // continue if the process is completed
                   if (request.readyState === 4) {
                       // continue only if HTTP status is good
                       if (request.status >= 200 && request.status < 300) {
                           // retrieve the response
                           callback(request.response ? JSON.parse(request.response) : null);
                       } else if (request.status === 401 && !retry) {
                           that.refreshAccessToken(function (oauthResponse) {
                               that.setSessionToken(oauthResponse.access_token, null, oauthResponse.instance_url);
                               that.blob(path, fields, filename, payloadField, payload, callback, error, true);
                           }, error);
                       } else {
                           // return status message
                           error(request, request.statusText, request.response);
                       }
                   }
               };
               /*request.upload.onprogress = function (event) {
                   if(window.forcetk.uploadProgress !== undefined){
                       window.forcetk.uploadProgress(event);
                   }
               };*/
           }
           request.send(blob);
           return this.asyncAjax ? null : JSON.parse(request.response);
       };
	},
    uploadFile : function (component, event, helper) {
        console.log('upload start');
        console.log(component.get('v.sessionId'));
        var client = new forcetk.Client();
        client.setSessionToken(component.get('v.sessionId'));
        client.instanceUrl = 'https://autumn16-developer-edition.na35.force.com';
        client.proxyUrl = null;
        client.visualforce = false;
        for(var i=0; i<event.target.files.length; i++){
            (function (file) {
              	console.log(file.name);
                client.createBlob('ContentVersion',{
                    Origin: 'H',
                    PathOnClient: file.name
                }, file.name, 'VersionData', file, function(response){
                    console.log(response);
                }, function(request, status, response){
                    document.getElementById("message").innerHTML = "Error: " + status;
                });
            })(event.target.files[i]);
        }
    }
})