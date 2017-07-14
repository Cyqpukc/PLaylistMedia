public with sharing class UserMediaCmpCtrl {
    private static Integer listSize = 1000;

    @AuraEnabled
    public static String getUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static List<String> getViewedMedia(String userId) {

        List<String> result = new List<String>();

        Id uId;
        if (String.isBlank(userId)) {
            uId = UserInfo.getUserId();
        } else {
            uId = userId;
        }
        //SE-1615: hide recently viewed if another user is viewing
        if (uId != UserInfo.getUserId()) {
            return result;
        }


        if(Util.isObject('scormanywhere__Transcript__c', Util.IS_ACCESSIBLE) &&
            Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
            // *** Note to the Salesforce security team
            //Transcript are private, guest and community users
            //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            List<scormanywhere__Transcript__c> transcripts = WithoutSharingController.getTranscripts(uId, listSize);

            for (scormanywhere__Transcript__c transcript : transcripts) {
                result.add(transcript.Id);
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<String> getUploadedMedia(String userId) {
        Id uId;
        if (String.isBlank(userId)) {
            uId = UserInfo.getUserId();
        } else {
            uid = userId;
        }

        List<scormanywhere__Course__c> courses;
        if (uid == UserInfo.getUserId()) {
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            if(Util.isObject('scormanywhere__Transcript__c', Util.IS_ACCESSIBLE) &&
                Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
                Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {

                courses = WithoutSharingController.getCourses(uId, listSize);
            }

        } else {
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            String query = getFilteredVideosQuery(userId);
            courses = WithoutSharingController.getDynamicQuery(query);
        }
        List<String> result = new List<String>();
        for (scormanywhere__Course__c course : courses) {
            result.add(course.Id);
        }
        return result;
    }

    @AuraEnabled
    public static String getFilteredVideosQuery(String userId) {
        String result = Util.getCourseTranscriptsSOQL();
        result += getWhereStatement(userId);
        result += 'ORDER BY CreatedDate DESC LIMIT ' + listSize;
        System.debug(result);
        return result;
    }

    @AuraEnabled
    public static String getWhereStatement(String userId) {
        Boolean isUserGuest = String.isBlank(UserInfo.getSessionId());
        String whereStatement = '';
        if(isUserGuest){
            whereStatement += 'WHERE OwnerId = \'' + userId + '\' AND scormanywhere__Status__c = \'Active\' AND (scormanywhere__Public__c = true)';
        } else{
            whereStatement += 'WHERE OwnerId = \'' + userId + '\' AND scormanywhere__Status__c = \'Active\' AND (id = \'\' OR ';
            List<String> condList = new List<String>();
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
                    //Courses are private, guest and community users
                    //have to have access to some courses, their access to those course is controlled by the application logic.
                    //That’s why we use ‘without sharing’ here.
                    for (SObject ca : WithoutSharingController.getDynamicQuery(queryCourseAccount)) {
                        courseIds.add((Id)ca.get('Course__c'));
                    }
                }
                condList.add('scormanywhere__Enable_all_external_users__c = true');
            } else {//if internal user
                condList.add('scormanywhere__Enable_all_internal_users__c = true');
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
        }
        return whereStatement;
    }

    @AuraEnabled
    public static List<MediaWrapper> getTranscripts(List<String> transcriptIds) {
        List<MediaWrapper> result = new List<MediaWrapper>();
        // *** Note to the Salesforce security team
        //Transcript are private, guest and community users
        //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        List<scormanywhere__Transcript__c> transcripts = WithoutSharingController.getTranscripts(transcriptIds);
        Set<Id> availableCourseIds = Util.getAvailableCourseIds(transcripts);

        for (scormanywhere__Transcript__c transcript : transcripts) {
            MediaWrapper tempCourse = new MediaWrapper(transcript);
            if (!availableCourseIds.contains(transcript.scormanywhere__Course__c)) {
                tempCourse.linkCourse = '';
            }
            result.add(tempCourse);
        }
        return result;
    }

    @AuraEnabled
    public static List<MediaWrapper> getCourses(String userId, List<String> courseIds) {
        Id uId;
        if (String.isBlank(userId)) {
            uId = UserInfo.getUserId();
        } else {
            uid = userId;
        }
        List<MediaWrapper> result = new List<MediaWrapper>();
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        List<scormanywhere__Course__c> courses = WithoutSharingController.getCourses(uid, courseIds);
        Set<Id> availableCourseIds = Util.getAvailableCourseIds(courses);

        for (scormanywhere__Course__c course : courses) {
            MediaWrapper tempCourse = new MediaWrapper(course);
            if (!availableCourseIds.contains(course.Id)) {
                tempCourse.linkCourse = '';
            }
            result.add(tempCourse);
        }

        return result;
    }

    @AuraEnabled
    public static String getPrefix() {
        System.debug('Site.getPathPrefix() - ' + Site.getPathPrefix());
        return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix() : '/s';
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
}