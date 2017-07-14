({
    doInit : function(cmp, event, helper) {
		  helper.getSessionId(cmp);
    },
    initUploader : function (cmp, event, helper) {
       forcetk.Client.prototype.blob = function (path, fields, filename, payloadField, payload, callback, error, retry) {
           'use strict';
           
           path =  '/v35.0/chatter/feed-elements/batch';
           console.log(fields);
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
           
           var that = this,
               url = (this.visualforce ? '' : this.instanceUrl) + '/services/data' + path,
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
               request.upload.onprogress = function (event) {
                   if(window.forcetk.uploadProgress !== undefined){
                       window.forcetk.uploadProgress(event);
                   }
               };
           }
           request.send(blob);
           return this.asyncAjax ? null : JSON.parse(request.response);
       };
    },
    sendFile : function (cmp, event, helper) {
        console.log('upload run');
        window.forcetk.uploadProgress = function (event) {
            console.log(event);
            var progressBar = document.getElementById('fileProgress');
            progressBar.classList.remove('slds-hide');
            progressBar.getElementsByClassName('status')[0].style.width = Math.ceil(event.loaded / event.total * 100)+'%';
        };
        var client = new forcetk.Client();
        client.setSessionToken(cmp.get('v.sessionId'));
        client.instanceUrl = 'https://teamprfcnt-americanexpressgcppartners.cs3.force.com';
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
    },
    save : function (cmp, event, helper) {
      helper.saveMedia(cmp);
    },
    getTitle : function (cmp, event, helper) {
      helper.getTitleMedia(cmp);
    },
    hiddenErrorModalBox : function(cmp, event, helper) {
        cmp.set("v.showErrorModal", false);
    }
})