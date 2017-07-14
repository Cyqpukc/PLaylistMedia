public with sharing class CommunityChatterUploaderCtrl {

    public static String courseId {get;set;}
    
    public String uploadId {get{
        if (uploadId != null) return uploadId;
        if (getPageParam().get('uploadid') != null) {
            return getPageParam().get('uploadid');
        } else {
            return null;
        }
    } set;}
    
    public String getUploadCourseUrl() {
        PageReference pageRef = Page.scormanywhere__UploadCourses;
        pageRef.getParameters().put('inline', '1');
        //pageRef.getParameters().put('chatter', '1');
        pageRef.getParameters().put('uploaderstyle', 'chatter');        
        //pageRef.getParameters().put('height', '250');
        String groupId = ApexPages.currentPage().getParameters().get('groupId');
        pageRef.getParameters().put('callbackURL', 
            'https://' + ApexPages.currentPage().getHeaders().get('Host') + Site.getPathPrefix()
            + Page.CommunityChatterUploader.getUrl() + '?UploaderStyle=Chatter' 
            + '&redirectURL=' + ApexPages.currentPage().getParameters().get('redirectURL')
            + ((groupId != null) ? '&groupId=' + groupId : '')
        );
        return Site.getPathPrefix() + pageRef.getUrl();
    }

    public void redirectWithParams() {
        if (uploadId != null) {
            scormanywhere__Course__c course = new scormanywhere__Course__c();
            if(Test.isRunningTest()){
                course = [SELECT Name FROM scormanywhere__Course__c LIMIT 1];
                courseId = course.id;
            } else {
                courseId = scormanywhere.ApiService.createCourse(uploadId);
                String groupId = ApexPages.currentPage().getParameters().get('groupId');
                postToFeed(courseId,'',groupId);
            }
            
        }
    }
    
    private Map<String, String> getPageParam() {
        Map<String, String> result = new Map<String, String>();
        String fullUrl = ApexPages.currentPage().getURL();
        if (fullUrl.indexOf('?')>=0) {
            List<String> partsOfUrl = multiSplit(fullUrl, new List<String>{'?','%3F'});
            partsOfUrl.remove(0);
            String paramsString = partsOfUrl[0];
            partsOfUrl.remove(0);
            if (partsOfUrl.size()>0) {
                for (String partOfUrl:partsOfUrl) {
                    paramsString += '&'+partOfUrl;
                }
            }
            List<String> paramsList = multiSplit(paramsString, new List<String>{'&','%26'});
            for (String paramSource:paramsList) {
                List<String> paramParts = multiSplit(paramSource, new List<String>{'=','%3D'});
                if (paramParts.size()==2) {
                    result.put(paramParts[0],paramParts[1]);
                }
            }
        }
        //LowerCase for keys of GET parameters fix
        for (String keyParam:result.keySet()) {
            if (!keyParam.equals(keyParam.toLowerCase())) {
                result.put(keyParam.toLowerCase(), result.get(keyParam));
                result.remove(keyParam);
            }
        }
        return result;
    }
    
    private List<String> multiSplit(String src, List<String> splitters) {
        List<String> result = src.split(splitters[0].replace('?','\\?').replace('%','\\%'));
        splitters.remove(0);
        for (String splitter:splitters) {
            String encodeSplitter = splitter.replace('?','\\?').replace('%','\\%');
            for (Integer i = 0; i<result.size(); i++) {
                if (result[i].indexOf(splitter)>=0) {
                    List<String> newSplit = result[i].split(encodeSplitter);
                    result.remove(i);
                    i--;
                    result.addAll(newSplit);
                }
            }
        }
        return result;
    }
    
    public static String postToFeed(Id cId, String message, Id groupId) { 
        scormanywhere__Course__c course = [SELECT Id, Name, scormanywhere__Thumbnail_Path__c, scormanywhere__SCORM_Manifest_Data__c FROM scormanywhere__Course__c WHERE Id=:cId];
        String addVideoParams = '';
        try {
            String jstr = course.scormanywhere__SCORM_Manifest_Data__c;
        	Map<String, Object> m =
          	 (Map<String, Object>)
           	   JSON.deserializeUntyped(jstr);
            addVideoParams = '&videoType='+String.valueOf(m.get('videoType'))+'&videoData='+EncodingUtil.urlEncode(String.valueOf(m.get('videoData')), 'UTF-8');
        } catch (exception e) {
            
        }
        //create feed
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.feedElementType  = ConnectApi.FeedElementType.FeedItem;
      	feedItemInput.subjectId = (groupId == null) ? 'me' : groupId;
        
        message = message == null ? '' :message;
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = message;
        
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        
        ConnectApi.LinkCapabilityInput inputLinkCapability = new ConnectApi.LinkCapabilityInput();
        inputLinkCapability.url = 
            'https://services.appinium.com/chatterplayer?courseid=' + course.Id 
            + '&title='+EncodingUtil.urlEncode(course.Name,'UTF-8') 
            + '&sfdomain=' + EncodingUtil.urlEncode(ApexPages.currentPage().getHeaders().get('Host') + Site.getPathPrefix(),'UTF-8')
            + addVideoParams;
            
        if (course.scormanywhere__Thumbnail_Path__c != null) {
			String fileName = course.scormanywhere__Thumbnail_Path__c;
            if(fileName != null) {
                List<String> parts = filename.split('/');
                fileName = parts.get(parts.size()-1);            
                inputLinkCapability.url += '&thumb='+EncodingUtil.urlEncode(fileName,'UTF-8');
            }
        }
        
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.link = inputLinkCapability;
        
        feedItemInput.capabilities = feedElementCapabilitiesInput;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        return '';
    }   
    
   
}