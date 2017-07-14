public with sharing  class MyMediaCmpCtrl {

    @AuraEnabled
    public static Boolean getPinAccess() {
        return
            scormanywhere__Channel__c.sObjectType.getDescribe().isCreateable() && scormanywhere__Channel__c.sObjectType.getDescribe().isDeletable()
            && scormanywhere__Channel_Course__c.sObjectType.getDescribe().isCreateable() && scormanywhere__Channel_Course__c.sObjectType.getDescribe().isDeletable();
    }

    @AuraEnabled
    public static MediaWrapper getVideoDetail(String courseId) {
        MediaWrapper result;
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        //Check only accessible to object and Name and Description

        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {

            // *** Note to the Salesforce security team
            //Courses are private, guest and community users have to see any records that's why without sharing
            List<scormanywhere__Course__c> courses = WithoutSharingController.getCoursesWithChannels(courseId);

            if (courses != null && !courses.isEmpty()) {
                result = new MediaWrapper(courses[0], getChannels());
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<MediaWrapper> getAllUserVideos(String searchTerm, String channelId) {
        List<MediaWrapper> result = new List<MediaWrapper>();

        if(Util.isObject('scormanywhere__Transcript__c', Util.IS_ACCESSIBLE)) {
            String query = getUserVideosQuery(searchTerm, channelId, 100);
            // *** Note to the Salesforce security team
            //Transcript are private, guest and community users
            //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.

            List<scormanywhere__Transcript__c> transcripts = withoutSharingController.getDynamicQuery(query);

            for (scormanywhere__Transcript__c transcript : transcripts) {
                result.add(new MediaWrapper(transcript));
            }
        }
        return result;
    }

    @AuraEnabled
    public static void updateTranscript(String transcriptId) {
        String query = 'SELECT Id, scormanywhere__Course__r.CreatedDate FROM scormanywhere__Transcript__c WHERE Id = \'' + transcriptId + '\' LIMIT 1' ;

        // *** Note to the Salesforce security team
        //Transcript are private, guest and community users
        //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        if(Util.isObject('scormanywhere__Transcript__c', Util.IS_ACCESSIBLE)) {
            List<scormanywhere__Transcript__c> transcripts = WithoutSharingController.getDynamicQuery(query);
            if (!transcripts.isEmpty()) {
                // *** Note to the Salesforce security team
                //Courses are private, guest and community users
                //have to have access to some courses, their access to those course is controlled by the application logic.
                //That’s why we use ‘without sharing’ here.
                WithoutSharingController.updateTranscript(transcripts);
            }
        }
    }

    @AuraEnabled
    public static String getUserVideosQuery(String searchTerm, String channelId, Integer maxCount) {
        if (maxCount == null || maxCount <= 0) {
            maxCount = 100;
        }
        String result = 'SELECT scormanywhere__Progress__c, scormanywhere__SCORM_Session_Time_Stamp__c, scormanywhere__SCORM_Attempt_Completion_Status__c, scormanywhere__SCORM_Attempt_Progress_Status__c, scormanywhere__Attempts__c, scormanywhere__Launch_Date__c, scormanywhere__SCORM_Progress_Measure__c, scormanywhere__SCORM_Progress_Status__c, scormanywhere__SCORM_Satisfied_Status__c, scormanywhere__SCORM_Scaled__c, scormanywhere__Total_Time__c, scormanywhere__Total_Time_Seconds__c, scormanywhere__Session_Time_Seconds__c, scormanywhere__Course__c, scormanywhere__Course__r.scormanywhere__Course_Version__c, scormanywhere__Course__r.scormanywhere__SCORM_Training_Type__c, scormanywhere__Course__r.scormanywhere__Completion_Progress_Threshold__c, scormanywhere__Test_Launch__c, scormanywhere__User__c, Id, scormanywhere__Course__r.Name, scormanywhere__Course__r.scormanywhere__Thumbnail_Path__c, scormanywhere__Course__r.scormanywhere__Description__c, scormanywhere__Course__r.CreatedDate, scormanywhere__Course__r.OwnerId, scormanywhere__Course__r.Owner.Name FROM scormanywhere__Transcript__c ';
        result += getWhereStatementTranscripts(searchTerm, channelId);
        result += ' ORDER BY LastModifiedDate DESC LIMIT ' + maxCount;
        System.debug('sql ' + result);
        return result;
    }

    @AuraEnabled
    public static String getWhereStatementTranscripts(String keyword, String channelId) {
        Boolean isForChannel = channelId != 'All';
        String whereStatement = ' WHERE scormanywhere__Course__c != null AND ';
        if (String.isNotBlank(keyword)) {
            keyword = keyword.replace(' ', '_');
            whereStatement += ' scormanywhere__Course__r.Name LIKE \'%' + String.escapeSingleQuotes(keyword) + '%\' AND ';
        }
        whereStatement += ' scormanywhere__User__c=\''+Userinfo.getUserId()+'\' AND scormanywhere__Test_Launch__c = false ' ;
        Set<Id> courseIds = new Set<Id>();
        if (isForChannel) {
            List<Id> channelCourseIds = Util.getCourseIdsForChannel(channelId);
            whereStatement += ' AND scormanywhere__Course__c IN (\'\',';
            for (Id courseId : channelCourseIds) {
                whereStatement += '\'' + courseId + '\',';
            }
            whereStatement = whereStatement.removeEnd(',') + ') ';
        }
        if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            whereStatement += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        return whereStatement;
    }

    @AuraEnabled
    public static List<ChannelWrapper> getChannels(){
        List<ChannelWrapper> result = new List<ChannelWrapper>();

        if(Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel__c', Util.IS_UPDATEABLE) &&
        Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            for(scormanywhere__Channel__c channels : WithoutSharingController.getChannelsTranscripts())
            {
                result.add(new ChannelWrapper(channels));
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<ChannelWrapper> removeChannel(String channelId){
        if(Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel__c', Util.IS_DELETABLE)) {
            scormanywhere__Channel__c result = [SELECT Id FROM scormanywhere__Channel__c WHERE Id = :channelId];
            delete result;
        }
        return getChannels();
    }

    @AuraEnabled
    public static List<ChannelWrapper> addChannel(String channelName, String mediaId) {
        if(Util.isObject('scormanywhere__Channel__c', Util.IS_CREATEABLE) && Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_ACCESSIBLE)) {
            scormanywhere__Channel__c newChannel = new scormanywhere__Channel__c();
            newChannel.scormanywhere__Title__c = channelName;
            insert newChannel;

            if(!String.isBlank(mediaId)){

                // *** Note to the Salesforce security team
                //We do not check "insert" permissions for the scormanywhere__Channel_Course__c and Course object here because we do not want regular users to have direct "insert" permission for this object,

                scormanywhere__Channel_Course__c newRecord = new scormanywhere__Channel_Course__c();
                newRecord.scormanywhere__Channel__c = newChannel.Id;
                newRecord.scormanywhere__Course__c = mediaId;
                List<scormanywhere__Channel_Course__c> ChannelCourses = new List<scormanywhere__Channel_Course__c>();
                ChannelCourses.add(newRecord);
                // *** Note to the Salesforce security team
                //Courses are private, guest and community users
                //have to have access to some courses, their access to those course is controlled by the application logic.
                //That’s why we use ‘without sharing’ here.
                WithoutSharingController.insertChannelCourses(ChannelCourses);
            }
        }
        return getChannels();
    }


    @AuraEnabled
    public static void addMediaToChannel(String channelId, String mediaId, String channelName){
        Util.addMediaToChannel(channelId, mediaId, channelName);
    }

    @AuraEnabled
    public static void  removeMediaFromChannel(String channelId, String mediaId){
        if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel_Course__c', Util.IS_DELETABLE)) {
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.

            WithoutSharingController.deleteChannelCourses(channelId, mediaId);
        }
    }

    @AuraEnabled
    public static List<ChannelWrapper> changeNameChannel(String channelId, String newName){
        if(Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel__c', Util.IS_UPDATEABLE) &&
        Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {
            scormanywhere__Channel__c channel = [SELECT Id, scormanywhere__Title__c FROM scormanywhere__Channel__c WHERE Id = :channelId];
            channel.scormanywhere__Title__c = newName;
            update channel;
        }
        return getChannels();
    }

    @AuraEnabled
    public static CarouselWrapper getCarouselData(String searchTerm, String channelId) {
        CarouselWrapper cw = new CarouselWrapper();
        List<MediaWrapper> videos = getAllUserVideos(searchTerm, channelId);
        System.debug('videos - ' + videos);
        final Integer VIDS_PER_PAGE = 6;
        final Integer VIDS_EXC = 4;

        if (!videos.isEmpty()) {
            if(videos.size() > 4){
                for(Integer i=0; i<4;i++){
                    videos.remove(0);
                }
            } else {
                videos.clear();
            }
            Integer sixCounter = 0;
            Integer currentPageIndex = 0;
            cw.pages.add(new CarouselPageWrapper());

            for (MediaWrapper vid : videos) {
                cw.pages[currentPageIndex].videoList.add(vid);
                sixCounter++;

                if (Math.mod(sixCounter, VIDS_PER_PAGE) == 0) {
                    cw.pages.add(new CarouselPageWrapper());
                    currentPageIndex++;
                    sixCounter = 0;
                }
            }
        }

        if (!cw.pages.isEmpty()) {
            cw.pages[0].cssClass = 'item active';
        }

        CarouselPageWrapper lastPage = cw.pages.size() > 0 ? cw.pages[cw.pages.size()-1] : null;
        if (lastPage != null) {
            if (lastPage.videoList.size() == 0) {
                cw.pages.remove(cw.pages.size()-1);
            } else {
                while (lastPage.videoList.size() < VIDS_PER_PAGE) {
                    lastPage.videoList.add(new MediaWrapper());
                }
            }
        }

        return cw;
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
}