public class UploaderCtrl {

    @AuraEnabled
    public static String getSessionId() {
        System.debug('UserInfo.getSessionId() - ' + UserInfo.getSessionId());
        return UserInfo.getSessionId();
    }

    @AuraEnabled
    public static String getPrefix() {
        System.debug('Site.getPathPrefix() - ' + Site.getPathPrefix());
        return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
    }

    @AuraEnabled
    public static String getSiteDomain() {
        System.debug('URL.getSalesforceBaseUrl().getHost() - ' + URL.getSalesforceBaseUrl().getHost());
        return URL.getSalesforceBaseUrl().getHost();
    }

    @AuraEnabled
    public static String convertToMedia(String docId) {
        System.debug('asdasdasd');

        try {
            System.debug('docId - ' + docId);
            SObject contentVersion = Database.query('SELECT Id, Title, FileType, Description, VersionNumber, PublishStatus, Course__c, ContentSize FROM ContentVersion WHERE Id =:docId');
            scormanywhere__Course__c newLocalCourse = new scormanywhere__Course__c(
                                                scormanywhere__Description__c = (String)contentVersion.get('Description'),
                                                scormanywhere__SCORM_Training_Path__c = 'sfdclocal://'+(String)contentVersion.get('Id'),
                                                scormanywhere__SCORM_Training_Type__c = (String)contentVersion.get('FileType'),
                                                scormanywhere__SCORM_Title__c = (String)contentVersion.get('Title'),
                                                scormanywhere__SCORM_File_Size__c = (Decimal)contentVersion.get('ContentSize'),
                                                scormanywhere__Status__c = 'Inactive',
                                                Name = getSymbolsText((String)contentVersion.get('Title'), 80)
                                            );
            insert newLocalCourse;

            /*contentVersion.put('Course__c', newLocalCourse.Id);
            Database.update(contentVersion);*/
            /*String redirectURL = ApexPages.currentPage().getParameters().get('redirectURL');
            System.debug('redirectURL - ' + redirectURL);
            if(!String.isBlank(redirectURL)){
                String groupId = ApexPages.currentPage().getParameters().get('groupId');
                postToFeed(newLocalCourse.Id,'',groupId);
            }*/
            return newLocalCourse.Id;
        } catch (System.QueryException sQE) {
            return sQE.getMessage();
        } catch (Exception e) {
            return e.getMessage();
        }
        return null;
    }

    @AuraEnabled
    public static scormanywhere__Course__c getMedia(String courseId) {
        try {
            System.debug('courseId - ' + courseId);
            scormanywhere__Course__c course = [SELECT Id, Name, scormanywhere__Description__c, scormanywhere__Thumbnail_Path__c, scormanywhere__SCORM_Training_Path__c FROM scormanywhere__Course__c WHERE Id = :courseId];
            return course;
        } catch (System.QueryException sQE) {
            System.debug('Error - ' + sQE);
            return null;
        }
    }

    @AuraEnabled
    public static String setDuration(scormanywhere__Course__c course, Id docId, String duration) {
        scormanywhere__Course__c c = new scormanywhere__Course__c(Id = course.Id, scormanywhere__Duration__c = duration.substringBefore('.'));
        update c;
    	return duration;
    }

    @AuraEnabled
    public static Boolean updateMedia(scormanywhere__Course__c course, String groupId, Boolean isPostChatter) {
        try {
            System.debug('course - ' + course);
            System.debug('isPostChatter - ' + isPostChatter);
            update course;
            if(isPostChatter){
                String path = (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
                String sfDomain = URL.getSalesforceBaseUrl().getHost() + path;
                postToFeed(course.Id, '', groupId, sfDomain);
            }
            return true;
        } catch (System.QueryException sQE) {
            System.debug('Error - ' + sQE);
            return false;
        }
    }

    private static String getSymbolsText(String value, Integer numberSymbols ) {
        if ( ! String.isEmpty(value)) {
            if (value.length() > numberSymbols) {
                value = value.substring(0, (numberSymbols-5)) + '...';
            } else {
                value = value;
            }
        }
        return value;
    }

    public static String postToFeed(Id cId, String message, Id groupId, String sfDomain) {
        System.debug('>>>>>>>>>>>');

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
        System.debug('>>>>>>>>>>>');
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
            + '&sfdomain=' + EncodingUtil.urlEncode(sfDomain,'UTF-8')
            + addVideoParams;

        if (course.scormanywhere__Thumbnail_Path__c != null) {
            String temp = Network.getLoginUrl(Network.getNetworkId());
            if (temp != null) {
                temp = temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/').removeEnd('/s');
            }
            String fileName = course.scormanywhere__Thumbnail_Path__c;
            if(fileName != null) {
                inputLinkCapability.url += '&thumb='+EncodingUtil.urlEncode(temp + fileName,'UTF-8');
            }
        }

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.link = inputLinkCapability;

        feedItemInput.capabilities = feedElementCapabilitiesInput;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        System.debug('>>>>>>>>>>>');
        return '';
    }
}