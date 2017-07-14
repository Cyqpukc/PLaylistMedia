public with sharing class AllMediaCmpCtrl {

    @AuraEnabled
    public static String getMediaLink(String courseId, String currentUrl) {
        return Util.createEmbeddedLink(courseId, currentUrl);
    }

    @AuraEnabled
    public static String getPublicLinkNewWindow(String myCourseId, String siteId) {
        return Util.getPublicLinkNewWindow(myCourseId, siteId);
    }

    @AuraEnabled
    public static String getPublicLinkAp(String myCourseId, String siteId, String domain, String autoplay) {
        return Util.getPublicLinkAp(myCourseId, siteId, domain, autoplay);
    }

    @AuraEnabled
    public static Boolean getPinAccess() {
        return
            !String.isBlank(UserInfo.getSessionId())
            && scormanywhere__Channel__c.sObjectType.getDescribe().isCreateable()
            && scormanywhere__Channel__c.sObjectType.getDescribe().isDeletable()
            && scormanywhere__Channel_Course__c.sObjectType.getDescribe().isCreateable()
            && scormanywhere__Channel_Course__c.sObjectType.getDescribe().isDeletable();
    }

    @AuraEnabled
    public static Boolean getShareAccess(String shareButtonStyle) {
        Boolean isGuest = String.isBlank(UserInfo.getSessionId());
        if(isGuest && shareButtonStyle.toLowerCase() != 'link'){
            return false;
        }
        return true;
    }

    @AuraEnabled
    public static String getUserType() {
        return UserInfo.getUserType();
    }

    @AuraEnabled
    public static MediaWrapper getVideoDetail(String courseId) {
        MediaWrapper result;
        //Check only accessible to object and Name and Description
        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {

            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            List<scormanywhere__Course__c> courses = WithoutSharingController.getCoursesWithChannels(courseId);

            if (courses != null && !courses.isEmpty()) {
                Set<Id> availableCourseIds = Util.getAvailableCourseIds(courses);
                result = new MediaWrapper(courses[0], getChannels(null));
                if (availableCourseIds == null || availableCourseIds.isEmpty()) {
                    result.linkCourse = '';
                }
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<String> getAllVideos(String searchTerm, String channelId, String catalogId) {
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        List<String> result = new List<String>();
        //List<MediaWrapper> result = new List<MediaWrapper>();

        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
            List<scormanywhere__Course__c> courses = WithoutSharingController.getDynamicQuery(searchTerm, channelId, catalogId, 1000);

            for (scormanywhere__Course__c course : courses) {
                result.add(course.Id);
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<MediaWrapper> getMedia(List<String> mediaIds) {
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        List<MediaWrapper> result = new List<MediaWrapper>();
        //List<MediaWrapper> result = new List<MediaWrapper>();
        String query = Util.getCourseTranscriptsSOQL();
        query += ' WHERE Id IN : verDocIds ORDER BY CreatedDate DESC ';

        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
            List<scormanywhere__Course__c> courses = WithoutSharingController.getDynamicQuery(query, mediaIds);
            Set<Id> availableCourseIds = Util.getAvailableCourseIds(courses);

            for (scormanywhere__Course__c course : courses) {
                MediaWrapper tempCourse = new MediaWrapper(course);
                if (!availableCourseIds.contains(course.Id)) {
                    tempCourse.linkCourse = '';
                }
                result.add(tempCourse);
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<MediaWrapper> getRecomendedVideos(String searchTerm, Integer maxCount) {

        Integer limitRecord = Integer.valueOf(maxCount);
        List<MediaWrapper> result = new List<MediaWrapper>();
        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            List<scormanywhere__Course__c> courses = WithoutSharingController.getDynamicQuery(searchTerm, 'All', null, limitRecord);
            Set<Id> availableCourseIds = Util.getAvailableCourseIds(courses);

            for (scormanywhere__Course__c course : courses) {
                MediaWrapper tempCourse = new MediaWrapper(course);
                if (!availableCourseIds.contains(course.Id)) {
                    tempCourse.linkCourse = '';
                }
                result.add(tempCourse);
            }
        }
        return result;
    }


//todo investigate
    @AuraEnabled
    public static List<ChannelWrapper> getChannels(String catalogId){
        List<ChannelWrapper> result = new List<ChannelWrapper>();

        String whereStatement = '';

            Object disabledCBISharingObj = Util.getDynamicCustomSetting('scormanywhere__ViewTrac_Settings__c', 'Disable_CreatedById_Sharing__c');
            Boolean disabledCBISharing = (disabledCBISharingObj != null && ((Boolean)disabledCBISharingObj) == true);
            whereStatement += 'WHERE scormanywhere__Course__r.scormanywhere__Status__c = \'Active\' AND (id = \'\' OR ';
            List<String> condList = new List<String>();
            if (!disabledCBISharing) {
                condList.add('scormanywhere__Course__r.OwnerId = \'' + UserInfo.getUserId() + '\' ');
            }
            // *** Note to the Salesforce security team
            //We do not check CRUD/FLS permissions for the User object here because the SOQL below should be able to "select" fields from that record in the user's context even if CRUD/FLS permissions are not set for that user.
            //This includes community user
            User currentUser = [
                SELECT Id, ContactId, Contact.AccountId, ProfileId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            Set<Id> courseIds = new Set<Id>();
            if(Util.isObjectFieldAccessibility('Course_Profile__c', 'Course__c, Profile_Id__c')){
                String profileId = '%' + String.valueOf(currentUser.ProfileId).substring(0,15) + '%';
                String queryCourseProfile = 'SELECT Id, Course__c FROM Course_Profile__c WHERE Profile_Id__c LIKE \'' + profileId + '\'';
                System.debug('queryCourseProfile - ' + queryCourseProfile);

                // *** Note to the Salesforce security team
                //Courses are private, guest and community users
                //have to have access to some courses, their access to those course is controlled by the application logic.
                //That’s why we use ‘without sharing’ here.

                for(SObject item : WithoutSharingController.getDynamicQuery(queryCourseProfile)){
                    courseIds.add((Id)item.get('Course__c')); // if course assigned to profile
                }
            }
            if (currentUser.ContactId != null) {//if external user
                Id accountId = currentUser.Contact.AccountId;
                if(Util.isObjectFieldAccessibility('Course_Account__c','Course__c, Account__c')){
                    String queryCourseAccount = 'SELECT Id, Course__c FROM Course_Account__c WHERE Account__c = \'' + accountId + '\'';
                // *** Note to the Salesforce security team
                //Courses are private, guest and community users have to see any records thats why select without sharing
                //without crud\fls becouse guest user and community users should not have permissions to Course_Profile__c
                // *** Note to the Salesforce security team
                //Courses are private, guest and community users
                //have to have access to some courses, their access to those course is controlled by the application logic.
                //That’s why we use ‘without sharing’ here.

                    for (SObject ca : WithoutSharingController.getDynamicQuery(queryCourseAccount)) {
                        courseIds.add((Id)ca.get('Course__c'));
                    }
                }
                condList.add('scormanywhere__Course__r.scormanywhere__Enable_all_external_users__c = true');
            } else {//if internal user
                condList.add('scormanywhere__Course__r.scormanywhere__Enable_all_internal_users__c = true');
            }
            if (!courseIds.isEmpty()) {
                String coursesId = 'Id IN (\'\',';
                for (Id courseId : courseIds) {
                    coursesId += '\'' + courseId + '\',';
                }
                coursesId = coursesId.removeEnd(',') + ')';
                condList.add(coursesId);
            }

            if(!condList.isEmpty()){
                for(String item : condList){
                    whereStatement += item + ' OR ';
                }
            }
            whereStatement = whereStatement.removeEnd('OR ');

            whereStatement += ') ';
        String query = 'SELECT Id, scormanywhere__Title__c, (SELECT Id, scormanywhere__Course__c FROM scormanywhere__Channels__r ' + whereStatement + ') FROM scormanywhere__Channel__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\'ORDER BY scormanywhere__Title__c';
        System.debug('query - ' + query);

        if(Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
           Util.isObject('scormanywhere__Channel__c', Util.IS_UPDATEABLE) &&
          Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {

            // *** Note to the Salesforce security team
            //Channel_Course are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.

            List<scormanywhere__Channel__c> channels = WithoutSharingController.getDynamicQuery(query);
            System.debug('channels - ' + channels);

            for(scormanywhere__Channel__c chan : channels)
            {
                result.add(new ChannelWrapper(chan));
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
        return getChannels(null);
    }

    @AuraEnabled
    public static List<ChannelWrapper> addChannel(String channelName, String mediaId) {
        if(Util.isObject('scormanywhere__Channel__c', Util.IS_CREATEABLE) && Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {
            scormanywhere__Channel__c newChannel = new scormanywhere__Channel__c();
            newChannel.scormanywhere__Title__c = channelName;
            insert newChannel;

            if(!String.isBlank(mediaId) && Util.isObject('scormanywhere__Channel_Course__c', Util.IS_CREATEABLE)){

                // *** Note to the Salesforce security team
                //We do not check "insert" permissions for the scormanywhere__Channel_Course__c and Course object here because we do not want regular users to have direct "insert" permission for this object,
                //so we use "without sharing" to allow a regular user, community user to indirectly insert a scormanywhere__Channel_Course__c.

                // *** Note to the Salesforce security team
                //Channel_Course are private, guest and community users
                //have to have access to some courses, their access to those course is controlled by the application logic.
                //That’s why we use ‘without sharing’ here.
                scormanywhere__Channel_Course__c newRecord = new scormanywhere__Channel_Course__c();
                newRecord.scormanywhere__Channel__c = newChannel.Id;
                newRecord.scormanywhere__Course__c = mediaId;
                List<scormanywhere__Channel_Course__c> ChannelCourses = new List<scormanywhere__Channel_Course__c>();
                ChannelCourses.add(newRecord);
                WithoutSharingController.insertChannelCourses(ChannelCourses);
            }
        }
        return getChannels(null);
    }


    @AuraEnabled
    public static void addMediaToChannel(String channelId, String mediaId, String channelName){
        Util.addMediaToChannel(channelId, mediaId, channelName);
    }

    @AuraEnabled
    public static List<String>  removeMediaFromChannel(String channelId, String mediaId){
        if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        Util.isObject('scormanywhere__Channel_Course__c', Util.IS_DELETABLE)) {
            // *** Note to the Salesforce security team
            //Channel_Course are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            WithoutSharingController.deleteChannelCourses(channelId, mediaId);
        }
        return getAllVideos('', channelId, null);
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
        return getChannels(null);
    }

    @AuraEnabled
    public static Boolean shareContent(String contentId, String emailTo) {
        return Util.sendMediaLink(contentId, emailTo);
    }

    @AuraEnabled
    public static Boolean shareCourseInCommunity(String contentId, String emailTo, String domain, String autoplay) {
        return Util.sendMediaLink(contentId, emailTo, domain, autoplay);
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
    @AuraEnabled
    public static String deleteRelatedMedia(String courseId) {
        WithoutSharingController.deleteRelatedMedia(courseId);

        return 'SUCCESS';
    }
}