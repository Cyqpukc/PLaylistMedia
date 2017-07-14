public without sharing class WithoutSharingController {


    // *** Note to the Salesforce security team
    //sObject are private, guest and community users
    //have to have access to some sObject, their access to those sObject is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<sObject> getDynamicQuery(String query) {
        return Database.query(query);
    }

    // *** Note to the Salesforce security team
    //sObject are private, guest and community users
    //have to have access to some sObject, their access to those sObject is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<sObject> getDynamicQuery(String query, String userId) {
        return Database.query(query);
    }

    // *** Note to the Salesforce security team
    //sObject are private, guest and community users
    //have to have access to some sObject, their access to those sObject is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<sObject> getDynamicQuery(String query, String userId, Set<Id> participatedGroupIds) {
        return Database.query(query);
    }

    // *** Note to the Salesforce security team
    //sObject are private, guest and community users
    //have to have access to some sObject, their access to those sObject is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<sObject> getDynamicQuery(String query, List<String> verDocIds) {
        return Database.query(query);
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static Database.SaveResult insertRelatedMedia(List<scormanywhere__Related_Media__c> relatedMedia) {
        List<Database.SaveResult> result = Database.insert(relatedMedia);
        if (result.size() > 0) {
            return result.get(0);
        }
        return null;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<scormanywhere__Related_Media__c> getRelatedMedia(String objectId) {
        String searchId = '%' + objectId +'%';
         return [
                SELECT Id, Name, scormanywhere__Course__c, scormanywhere__Course__r.Name, scormanywhere__Course__r.scormanywhere__Thumbnail_Path__c, scormanywhere__Course__r.scormanywhere__SCORM_Training_Type__c
                FROM scormanywhere__Related_Media__c
                WHERE scormanywhere__Course__c != null
                    AND scormanywhere__Object_Id__c LIKE : searchId
                ORDER BY CreatedDate DESC
                LIMIT 100];
    }
    // *** Note to the Salesforce security team
    //sObject are private, guest and community users
    //have to have access to some sObject, their access to those sObject is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<List<sObject>> getDynamicSearchQuery(String query) {
        return Search.query(query);
    }

    // *** Note to the Salesforce security team
    //ApexClass CRUD/FLS and Sharing permissions cannot be set at the profile level
    //(this object is not displayed on the permissions page).
    //We use ‘without sharing’ and use application logic to limit access to this object.
    public static List<ApexClass> getApexClassesForPlugin(String pluginClass) {
        List<ApexClass> pluginClasses = [
            SELECT
                Id
                ,Name
                ,NamespacePrefix
            FROM
                ApexClass
            WHERE
                Name = :pluginClass
                AND Status = 'Active'
        ];
        return pluginClasses;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<scormanywhere__Course__c> getCoursesWithChannels(String courseId) {
        return [SELECT Id, Name, scormanywhere__Thumbnail_Path__c, CreatedDate, OwnerId, Owner.Name, scormanywhere__SCORM_Training_Type__c,
                        (SELECT Id, scormanywhere__Channel__c FROM scormanywhere__Courses__r)
                FROM scormanywhere__Course__c
                WHERE Id = :courseId
                LIMIT 1
            ];
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static scormanywhere__Channel__c getChannelWithCourseIds(String channelId) {
        return [
            SELECT Id, scormanywhere__Title__c, (SELECT Id, scormanywhere__Course__c FROM scormanywhere__Channels__r)
            FROM scormanywhere__Channel__c
            WHERE Id = :channelId
        ];
    }

    // *** Note to the Salesforce security team
    // *** Note to the Salesforce security team
    //Catalogs are private, guest and community users
    //have to have access to some Catalogs, their access to those Catalog is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static scormanywhere__Catalog__c getCatalogWithCourseIds(String catalogId) {
        return [SELECT Id, Name, (SELECT Id, scormanywhere__Course__c FROM scormanywhere__Course_Catalogs__r)
                FROM scormanywhere__Catalog__c
                WHERE Id = :catalogId
        ];


    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static void insertChannelCourses(List<scormanywhere__Channel_Course__c> ChannelCourses) {
        insert ChannelCourses;
    }

    // *** Note to the Salesforce security team
    //Transcript are private, guest and community users
    //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static void updateTranscript(List<scormanywhere__Transcript__c> transcripts) {
        upsert transcripts;
    }

    // *** Note to the Salesforce security team
    //Transcript are private, guest and community users
    //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static list<scormanywhere__Transcript__c> getMyTranscripts() {
        String query = 'SELECT Id, scormanywhere__Progress__c, scormanywhere__User__c, scormanywhere__Course__c ' +
					   'FROM scormanywhere__Transcript__c ' +
            		   'WHERE scormanywhere__User__c =\'' + UserInfo.getUserId() + '\' ' +
            		   'AND scormanywhere__Test_Launch__c = false ';
		if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            query += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        List<scormanywhere__Transcript__c> transcripts = getDynamicQuery(query);
        return transcripts;
    }


    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static void deleteChannelCourses(String channelId, String mediaId) {
        List<scormanywhere__Channel_Course__c> delRecord = [SELECT Id
                                          FROM scormanywhere__Channel_Course__c
                                          WHERE scormanywhere__Channel__c = : channelId
                                          AND scormanywhere__Course__c = : mediaId
                                          LIMIT 1];
        if(!delRecord.isEmpty()){
            delete delRecord[0];
        }
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static void deleteChannelCourseRecords(List<scormanywhere__Channel_Course__c> delRecords) {
        delete delRecords;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<sObject> getDynamicQuery(String searchTerm, String channelId, String catalogId, Integer maxCount) {
        return Database.query(getVideosQuery(searchTerm, channelId, catalogId, maxCount));
    }

    public static String getWhereStatement(String keyword, String channelId, String catalogId) {
        Boolean isForChannel = (channelId != 'All' && channelId != null && channelId != '');
        Boolean isForCatalog = (!isForChannel && catalogId != null &&  catalogId != '');
        Boolean isUserGuest = String.isBlank(UserInfo.getSessionId());
        String whereStatement = '';
        if (keyword != null && keyword != '') {
            keyword = keyword.replace(' ', '_');
        }
        if(isUserGuest){
            whereStatement += ' WHERE Name LIKE \'' +  String.escapeSingleQuotes(keyword) + '\' AND scormanywhere__Status__c = \'Active\' AND (scormanywhere__Public__c = true)';
        } else{
            Object disabledCBISharingObj = Util.getDynamicCustomSetting('scormanywhere__ViewTrac_Settings__c', 'Disable_CreatedById_Sharing__c');
            Boolean disabledCBISharing = (disabledCBISharingObj != null && ((Boolean)disabledCBISharingObj) == true);
            whereStatement += 'WHERE Name LIKE \'' +  String.escapeSingleQuotes(keyword) + '\' AND scormanywhere__Status__c = \'Active\' AND (id = \'\' OR ';
            List<String> condList = new List<String>();
            if (!disabledCBISharing) {
                condList.add('OwnerId = \'' + UserInfo.getUserId() + '\' ');
            }
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
                for(SObject item : Database.query(queryCourseProfile)){
                    courseIds.add((Id)item.get('Course__c')); // if course assigned to profile
                }
            }
            if (currentUser.ContactId != null) {//if external user
                Id accountId = currentUser.Contact.AccountId;
                if(Util.isObjectFieldAccessibility('Course_Account__c','Course__c, Account__c')){
                    String queryCourseAccount = 'SELECT Id, Course__c FROM Course_Account__c WHERE Account__c = \'' + accountId + '\'';
                    for (SObject ca : Database.query(queryCourseAccount)) {
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
        if (isForChannel) {
            List<Id> channelCourseIds = Util.getCourseIdsForChannel(channelId);
            whereStatement += ' AND Id IN (\'\',';
            for (Id courseId : channelCourseIds) {
                whereStatement += '\'' + courseId + '\',';
            }
            whereStatement = whereStatement.removeEnd(',') + ') ';
        }
        if (isForCatalog) {
            List<Id> catalogCourseIds = Util.getCourseIdsForCatalog(catalogId);
            whereStatement += ' AND Id IN (\'\',';
            for (Id courseId : catalogCourseIds) {
                whereStatement += '\'' + courseId + '\',';
            }
            whereStatement = whereStatement.removeEnd(',') + ') ';
        }
        return whereStatement;
    }

    public static String getVideosQuery(String searchTerm, String channelId, String catalogId, Integer maxCount) {
        if (maxCount == null || maxCount <= 0) {
            maxCount = 100;
        }
        String keyword = String.isNotBlank(searchTerm) ? '%' + String.escapeSingleQuotes(searchTerm) + '%' : '%%';
        String result = Util.getCourseTranscriptsSOQL();

        result += getWhereStatement(keyword, channelId, catalogId);
        result += 'ORDER BY CreatedDate DESC LIMIT ' + maxCount;
        System.debug(result);
        return result;
    }


    // *** Note to the Salesforce security team
    //Transcript are private, guest and community users
    //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<scormanywhere__Transcript__c> getTranscripts(String uId, Integer listSize) {
        String query = 'SELECT Id, scormanywhere__Progress__c, scormanywhere__Course__c, scormanywhere__Course__r.Name, scormanywhere__Course__r.OwnerId, scormanywhere__Course__r.Owner.Name, scormanywhere__Course__r.scormanywhere__Thumbnail_Path__c, scormanywhere__Course__r.scormanywhere__SCORM_Training_Type__c, scormanywhere__Course__r.scormanywhere__Description__c, scormanywhere__Course__r.CreatedDate, LastModifiedDate ' +
					   'FROM scormanywhere__Transcript__c ' +
            		   'WHERE scormanywhere__User__c =\'' + uId + '\' ' +
            		   'AND scormanywhere__Test_Launch__c = false ' +
        			   'AND scormanywhere__Course__c != null ';
		if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            query += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        query += 'ORDER BY LastModifiedDate DESC LIMIT ' + listSize;
        List<scormanywhere__Transcript__c> transcripts = getDynamicQuery(query);
        return transcripts;
    }

    // *** Note to the Salesforce security team
    //Transcript are private, guest and community users
    //have to have access to some Transcript, their access to those Transcript is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<scormanywhere__Transcript__c> getTranscripts(List<String> transcriptIds) {
        String query = 'SELECT Id, scormanywhere__Progress__c, scormanywhere__Course__c, scormanywhere__Course__r.Name, scormanywhere__Course__r.OwnerId, scormanywhere__Course__r.Owner.Name, scormanywhere__Course__r.scormanywhere__Thumbnail_Path__c, scormanywhere__Course__r.scormanywhere__SCORM_Training_Type__c, scormanywhere__Course__r.scormanywhere__Description__c, scormanywhere__Course__r.CreatedDate, LastModifiedDate ' +
					   'FROM scormanywhere__Transcript__c ' +
            		   'WHERE scormanywhere__Course__c != null AND Id IN (\'\',';
        for (Id courseId : transcriptIds) {
             query += '\'' + courseId + '\',';
        }
        query = query.removeEnd(',') + ') ';
		if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            query += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        query += 'ORDER BY LastModifiedDate DESC';
        List<scormanywhere__Transcript__c> transcripts = getDynamicQuery(query);
        return transcripts;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<scormanywhere__Course__c> getCourses(String uId, Integer listSize) {
        String query = Util.getCourseTranscriptsSOQL();
        query += ' WHERE OwnerId = :uId ORDER BY CreatedDate DESC LIMIT :listSize';
        List<scormanywhere__Course__c> courses = Database.query(query);
        return courses;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static List<scormanywhere__Course__c> getCourses(String uId, List<String> courseIds) {
        String query = Util.getCourseTranscriptsSOQL();
        query += ' WHERE Id IN : courseIds ORDER BY CreatedDate DESC';
        List<scormanywhere__Course__c> courses = Database.query(query);
        return courses;
    }
    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<scormanywhere__Channel__c> getChannels(){
        return [SELECT Id, scormanywhere__Title__c, (SELECT Id, scormanywhere__Course__c FROM scormanywhere__Channels__r LIMIT 1000)
                                       FROM scormanywhere__Channel__c
                                       WHERE CreatedById = : UserInfo.getUserId()
                                       ORDER BY scormanywhere__Title__c];
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<scormanywhere__Channel__c> getChannelsTranscripts(){

        String query = 'SELECT Id, scormanywhere__Course__c FROM scormanywhere__Transcript__c WHERE scormanywhere__Course__c != null AND ';
        query += ' scormanywhere__User__c=\''+Userinfo.getUserId()+'\' AND scormanywhere__Test_Launch__c = false ';
        if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            query += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        query += ' LIMIT 5000';
        Set<String> courseIds = new Set<String>();
        for(scormanywhere__Transcript__c item : Database.query(query)){
            courseIds.add(item.scormanywhere__Course__c);
        }

        return [SELECT Id, scormanywhere__Title__c, (SELECT Id, scormanywhere__Course__c FROM scormanywhere__Channels__r WHERE scormanywhere__Course__c IN : courseIds LIMIT 1000)
                                       FROM scormanywhere__Channel__c
                                       WHERE CreatedById = : UserInfo.getUserId()
                                       ORDER BY scormanywhere__Title__c];
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static List<scormanywhere__Channel_Course__c> getChannelCourses(String mediaId, String targetChannelId){
        return [
                    SELECT Id, scormanywhere__Channel__c, scormanywhere__Course__c
                    FROM scormanywhere__Channel_Course__c
                    WHERE scormanywhere__Course__c = :mediaId
                        AND scormanywhere__Channel__c = :targetChannelId
                ];
    }
    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static scormanywhere__Course__c getSingleCourse(String contentId) {
       list<scormanywhere__Course__c> contents = [SELECT Id, Name, scormanywhere__Description__c, scormanywhere__Thumbnail_Path__c, scormanywhere__SCORM_Training_Type__c, scormanywhere__SCORM_Manifest_Data__c, scormanywhere__SCORM_Training_Path__c, scormanywhere__Public__c FROM scormanywhere__Course__c WHERE Id = :contentId LIMIT 1];
       if (contents.size() > 0) {
           return contents.get(0);
       }
       return null;
    }
    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static scormanywhere__Course__c getSingleCourseWithThumb(String contentId) {
       list<scormanywhere__Course__c> contents = [SELECT Id, Name, scormanywhere__Description__c, scormanywhere__Thumbnail_Path__c, scormanywhere__SCORM_Manifest_Data__c, scormanywhere__SCORM_Training_Path__c FROM scormanywhere__Course__c WHERE Id = :contentId AND scormanywhere__Thumbnail_Path__c != null LIMIT 1];
       if (contents.size() > 0) {
           return contents.get(0);
       }
       return null;
    }
    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.

    public static list<scormanywhere__Course__c> getAllCourses() {
        return [
                SELECT Id, Name
                FROM scormanywhere__Course__c
                WHERE scormanywhere__Public__c = true
                ORDER BY Name LIMIT 1000
            ];
    }

    public static String getSfThumbLinkForChatter(String versionId){
        String link;
        String publicPreviewLink;
        String conDistName = 'shared-' + versionId;
        String conDistId = null;

        //if (Util.isObjectFieldAccessibility('ContentDistribution', null)) {
        List<sObject> existingConDist = Database.query('SELECT Id, Name FROM ContentDistribution WHERE Name = :conDistName');
        System.debug('existingConDist - ' + existingConDist);
        if (existingConDist == null || existingConDist.isEmpty()) {
            sObject conDist = Schema.getGlobalDescribe().get('ContentDistribution').newSObject();
            conDist.put('ContentVersionId', versionId);
            conDist.put('Name', conDistName);
            conDist.put('OwnerId', UserInfo.getUserId());
            conDist.put('PreferencesAllowOriginalDownload', true);
            conDist.put('PreferencesAllowPDFDownload', false);
            conDist.put('PreferencesAllowViewInBrowser', true);
            conDist.put('PreferencesExpires', false);
            conDist.put('PreferencesLinkLatestVersion', false);
            conDist.put('PreferencesNotifyOnVisit', false);
            conDist.put('PreferencesNotifyRndtnComplete', false);
            conDist.put('PreferencesPasswordRequired', false);
            insert conDist;
            conDistId = conDist.Id;
        } else {
            conDistId = (String)existingConDist[0].get('Id');
        }
        System.debug('conDistId - ' + conDistId);

        List<sObject> paths = Database.query('SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE Id = :conDistId LIMIT 1');
        System.debug('paths - ' + paths);
        if (paths != null && !paths.isEmpty()) {
            publicPreviewLink = (String)paths[0].get('DistributionPublicUrl');
        }
        if (publicPreviewLink != null) {
            list<String> publicPreviewLinkParts = publicPreviewLink.split('/a/');
            system.debug(publicPreviewLinkParts);
            if (publicPreviewLinkParts.size() > 0) {
                list<String> domainsParts = publicPreviewLinkParts[0].split('/sfc');
                if (domainsParts.size() > 0) {
                 link = domainsParts[0]+'/sfc/dist/version/download/?oid='+UserInfo.getOrganizationId()+'&ids='+versionId+'&d='+EncodingUtil.urlEncode('/a/'+publicPreviewLinkParts[1],'UTF-8');
                }
            }
        }
        return link;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static scormanywhere__Course__c getCourse(String courseId) {
        List<scormanywhere__Course__c> courses = [SELECT Id, Name, scormanywhere__Enable_all_external_users__c, scormanywhere__Enable_all_internal_users__c, scormanywhere__Public__c FROM scormanywhere__Course__c  WHERE  Id = :courseId];
        if(!courses.isEmpty()){
            if(String.isBlank(UserInfo.getSessionId())){
                if(courses[0].scormanywhere__Public__c){
                    return courses[0];
                }
            } else{
                User currentUser = [
                                    SELECT Id, ContactId, Contact.AccountId, ProfileId
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()
                                    ];
                if (currentUser.ContactId != null) {//if external user
                    if(courses[0].scormanywhere__Enable_all_external_users__c){
                        return courses[0];
                    }
                } else {//if internal user
                    if(courses[0].scormanywhere__Enable_all_internal_users__c){
                        return courses[0];
                    }
                }
            }
        }
        return null;
    }

    // *** Note to the Salesforce security team
    //Courses are private, guest and community users
    //have to have access to some courses, their access to those course is controlled by the application logic.
    //That’s why we use ‘without sharing’ here.
    public static void deleteRelatedMedia(String courseId) {
        scormanywhere.GlobalHelper.setGlobalValue('enableCourseTrigger', false);
        List<scormanywhere__Transcript__c> transcriptList = [
            SELECT Id, Name
            FROM scormanywhere__Transcript__c
            WHERE scormanywhere__Course__c = :courseId
            LIMIT 1
        ];
        if (!transcriptList.isEmpty()) {
            delete transcriptList.get(0);
        }

        List<scormanywhere__Course__c> courseList = [
            SELECT Id, Name
            FROM scormanywhere__Course__c
            WHERE Id = :courseId
            LIMIT 1
        ];
        if (!courseList.isEmpty()) {
            delete courseList.get(0);
        }
    }
}