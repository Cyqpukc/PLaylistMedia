public with sharing class PostToMyFeedCtrl{
    @AuraEnabled
    public static String postToMyFeedCtrl(Id courseId, String message) {
		// *** Note to the Salesforce security team
		//Courses are private, guest and community users
		//have to have access to some courses, their access to those course is controlled by the application logic.
		//That’s why we use ‘without sharing’ here.
        scormanywhere__Course__c course = new scormanywhere__Course__c();
        if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE)) {
        	course = WithoutSharingController.getSingleCourse(courseId);
        }

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
        feedItemInput.subjectId = 'me';

        message = message == null ? '' :message;
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = message;

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;

        ConnectApi.LinkCapabilityInput inputLinkCapability = new ConnectApi.LinkCapabilityInput();
        Url domain = new Url(System.Url.getSalesforceBaseUrl().toExternalForm());
        String commonLink = domain.getHost()+ (Site.getPathPrefix() != '/s'?Site.getPathPrefix().removeEnd('/s'):'');
        String domainForChatterLink = Util.getDomainForChatterLink();
        String chatterLink;
        if(String.isNotBlank(domainForChatterLink)){
            chatterLink = domainForChatterLink;
        } else {
            chatterLink = 'https://services.appinium.com';
        }
        chatterLink += '/chatterplayer?courseid='+course.Id+'&showSFPlayer=1&title='+EncodingUtil.urlEncode(course.Name,'UTF-8')+'&sfdomain='+EncodingUtil.urlEncode(commonLink,'UTF-8')+'&courseType=';
        if(!String.isBlank(course.scormanywhere__SCORM_Training_Type__c)){
            chatterLink += EncodingUtil.urlEncode(course.scormanywhere__SCORM_Training_Type__c,'UTF-8');
        }
        chatterLink += addVideoParams;
        inputLinkCapability.url = chatterLink;
        if (course.scormanywhere__Thumbnail_Path__c != null) {
            String fileName = course.scormanywhere__Thumbnail_Path__c;
            if(fileName != null) {
	            if (fileName.startsWith('/sfc') == true) {
                	String thumbUrl = EncodingUtil.urlEncode(fileName,'UTF-8');
                        inputLinkCapability.url += '&thumb='+thumbUrl.substringBefore('%26uploadId%3D') + '&uploadId='  + thumbUrl.substringAfter('%26uploadId%3D') + '&sfThumb=' + EncodingUtil.urlEncode(WithoutSharingController.getSfThumbLinkForChatter(fileName.substringAfter('download/').substringBefore('?')), 'UTF-8');
	            } else {
	                List<String> parts = filename.split('/');
	                fileName = parts.get(parts.size()-1);
	                inputLinkCapability.url += '&thumb='+EncodingUtil.urlEncode(fileName,'UTF-8');
	            }
            }
        }

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.link = inputLinkCapability;

        feedItemInput.capabilities = feedElementCapabilitiesInput;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        return '';
    }
}