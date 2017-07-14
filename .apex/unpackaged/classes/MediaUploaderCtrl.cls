global with sharing class MediaUploaderCtrl {

    public String urlForUpload {get; set;}
    public String urlForGetStatus {get; set;}
    public String urlForCheckFile {get; set;}
    public String urlForGetProgress {get; set;}
    public String guid {get; set;}
    public String orgId {get; set;}
    public Boolean isUploadMediaAccessible {get; set;}
    public Boolean isAsyncUpload {
        get{
            return !compareValues('syncUpload', false);
        }
        set;}
    //public String customCss {get; set;}


    public void init(){
        if(!Test.isRunningTest()){
            urlForUpload = scormanywhere.ApiService.getLink('UploadApi', null);
            urlForGetProgress = scormanywhere.ApiService.getLink('GetProgress', null);
            urlForGetStatus = scormanywhere.ApiService.getLink('GetStatus', null);
            urlForCheckFile = scormanywhere.ApiService.getLink('CheckFile', null);
        } else{
            urlForUpload = 'testurl&uploadId=124-234-234&testparam=11111';
            urlForGetProgress = 'testprogress';
            urlForGetStatus = 'teststatus';
            urlForCheckFile = 'checkFile';
        }
        guid = getStringParameterFromURL('uploadId', urlForUpload);
        guid = guid.toLowerCase();
        orgId = UserInfo.getOrganizationId();
        isUploadMediaAccessible = checkMediaAccess();
    }

    private Boolean checkMediaAccess() {
        return scormanywhere__Related_Media__c.sObjectType.getDescribe().isCreateable()
            && scormanywhere__Course__c.sObjectType.getDescribe().isCreateable();
    }

    private String getStringParameterFromURL(String parameterName, String stringUrl) {
        if(!String.isBlank(stringUrl)){
            Map<String, String> paramsByName = new Map<String, String>();
            for(String item : stringUrl.split('&')){
                paramsByName.put(item.substringBefore('='), item.substringAfter('='));
            }
            return paramsByName.get(parameterName);
        }
        return null;
    }

    @RemoteAction
    global static String getCoursesFromBackend(String uploadId) {
        String result = '';
        if(!Test.isRunningTest()){
            result = scormanywhere.ApiService.createCourse(uploadId);
        }
        System.debug('result - ' + result);
        return result;
    }

    @AuraEnabled
    public static void createNewMediaContent(String courseId, String parentId) {
        Id recordId = Id.valueOf(parentId);
        System.debug('recordId - ' + recordId);
        System.debug('courseId - ' + courseId);

        if(Util.isObject('scormanywhere__Related_Media__c', Util.IS_ACCESSIBLE) &&
            Util.isObject('scormanywhere__Related_Media__c', Util.IS_CREATEABLE) &&
            Util.isField('scormanywhere__Related_Media__c', 'scormanywhere__Course__c,scormanywhere__Object_Id__c,scormanywhere__Object_API_Name__c', Util.IS_CREATEABLE)) {
            scormanywhere__Related_Media__c newRMedia = new scormanywhere__Related_Media__c();
            newRMedia.scormanywhere__Course__c = courseId;
            newRMedia.scormanywhere__Object_Id__c = recordId;
            newRMedia.scormanywhere__Object_API_Name__c = recordId.getSObjectType().getDescribe().getName();
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users have to see any records that's why without sharing
            List<scormanywhere__Related_Media__c> RelatedMedia = new List<scormanywhere__Related_Media__c>();
            RelatedMedia.add(newRMedia);
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            Database.SaveResult result = WithoutSharingController.insertRelatedMedia(RelatedMedia);
            System.debug('result - ' + result);
        }
    }

    @AuraEnabled
    public static Boolean uploadToSF() {
        Boolean enableExternalContent = getIsExternalStorageEnabled ();
        Boolean enableSalesforceContent = getIsLocalStorageEnabled ();
        if(!enableExternalContent && enableSalesforceContent){
            return true;
        }
        return false;
    }

    public static scormanywhere__ViewTrac_Settings__c vtSettings  = scormanywhere__ViewTrac_Settings__c.getOrgDefaults();

    public static Boolean getIsLocalStorageEnabled () {
        return compareValues('Salesforce', false);
    }

    public static Boolean getIsExternalStorageEnabled () {
        return compareValues('External', true);
    }

    private static Boolean compareValues(String valForCompare, Boolean defaultValue) {
        try {
            String storageValue = vtSettings.scormanywhere__Content_Storage__c;
            if (storageValue != null && storageValue != '') {
                List<String> storageValues = storageValue.split(',');
                String value = getValueFromStorage(valForCompare, storageValues);
                Boolean test = value == valForCompare.toLowerCase().trim();
                return test;
            }
        } catch (system.exception e) {

        }
        return defaultValue;
    }

    private static String getValueFromStorage(String value, List<String> values) {
        if (values.size() == 0) {
            return null;
        }
        for (String v : values) {
            if (value != null && v != null) {
                if (value.toLowerCase() == v.toLowerCase().trim()) {
                    return v.toLowerCase().trim();
                }
            }
        }
        return null;
    }

    @AuraEnabled
    public static scormanywhere__Course__c getMedia(String courseId) {
        try {
            System.debug('courseId - ' + courseId);
            // *** Note to the Salesforce security team
            //Courses are private, guest and community users
            //have to have access to some courses, their access to those course is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.
            if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE)) {
                scormanywhere__Course__c course = WithoutSharingController.getSingleCourse(courseId);
                try {
                    String query = 'SELECT Uploaded_Media_Default_Name__c FROM scorm_engine__c LIMIT 1';
                    List<sObject> results = Database.Query(query);
                    if (!results.isEmpty()) {
                        String defNameCourse = (String)results.get(0).get('Uploaded_Media_Default_Name__c');
                        course.Name = !String.isBlank(defNameCourse) ? defNameCourse : '';
                    }
                } catch(Exception e) {
                    System.debug(LoggingLevel.Info, e.getMessage());
                }
                return course;
            }
            return null;
        } catch (System.QueryException sQE) {
            System.debug('Error - ' + sQE);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean updateMedia(scormanywhere__Course__c course) {
        try {
            // *** Note to the Salesforce security team
            //We do not want regular users to have direct access to the Course object via CRUD/FLS settings
            //to allow a regular user to indirectly update certain fields from the Course object during an upload new course.
            //This includes regular users, community user.
            update course;
            return true;
        } catch (System.QueryException sQE) {
            System.debug('Error - ' + sQE);
            return false;
        }
    }

    @RemoteAction
    global static String convertToMedia(String jsonString) {
        String docId = '';
        String thumbId = '';
        String domain = '';
        String duration = '';
        String uploadId = '';
        try {
            Map<String, Object> mapParams = new Map<String, Object>();
            try {
                system.debug('jsonString: '+jsonString);
                mapParams = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                system.debug('mapParams : '+mapParams);
                docId = String.escapeSingleQuotes(String.valueOf(mapParams.get('videoContentVersionId')));
                domain = String.escapeSingleQuotes(String.valueOf(mapParams.get('domain')));
                uploadId = String.escapeSingleQuotes(String.valueOf(mapParams.get('uploadId')));
            } catch (Exception e) {
                docId = jsonString;
            }

            try{
                thumbId = String.escapeSingleQuotes(String.valueOf(mapParams.get('thumbVersionId')));
            } catch (Exception e){}

            try{
                duration = String.escapeSingleQuotes(String.valueOf(mapParams.get('duration')));
            } catch (Exception e){}

            List<String> verDocIds = new List<String>();
            verDocIds.add(docId);
            if(!String.isBlank(thumbId)){
                verDocIds.add(thumbId);
            }

            // *** Note to the Salesforce security team
            //ContentVersion CRUD/FLS and Sharing permissions cannot be set at the profile level
            //(this object is not displayed on the permissions page).
            //We use ‘without sharing’ and use application logic to limit access to this object.

            Map<Id, SObject> contentVersions = new Map<Id, SObject> (WithoutSharingController.getDynamicQuery('SELECT Id, Title, FileType, Description, VersionNumber, PublishStatus, ContentSize, ContentDocumentId FROM ContentVersion WHERE Id IN :verDocIds', verDocIds));

            if(contentVersions.containsKey(docId)){
               scormanywhere__Course__c newLocalCourse = new scormanywhere__Course__c(
                   scormanywhere__Description__c = (String)contentVersions.get(docId).get('Description'),
                   scormanywhere__SCORM_Training_Path__c = 'sfdclocal://'+(String)contentVersions.get(docId).get('Id'),
                   scormanywhere__SCORM_Training_Type__c = (String)contentVersions.get(docId).get('FileType'),
                   scormanywhere__SCORM_Title__c = (String)contentVersions.get(docId).get('Title'),
                   scormanywhere__SCORM_File_Size__c = (Decimal)contentVersions.get(docId).get('ContentSize'),
                   scormanywhere__Duration__c = String.isBlank(duration) ? '' : (duration + ' sec'),
                   scormanywhere__Status__c = 'Active',
                   Name = getSymbolsText((String)contentVersions.get(docId).get('Title'), 80)
               );
               list<String> docIds = new List<String>();
               docIds.add((String)contentVersions.get(docId).get('ContentDocumentId'));
               if (!String.isBlank(thumbId)) {
                   newLocalCourse.scormanywhere__Thumbnail_Path__c = '/sfc/servlet.shepherd/version/download/'+thumbId;
                   if(contentVersions.containsKey(thumbId)){
                     String thumbFileTitle = String.escapeSingleQuotes((String)contentVersions.get(thumbId).get('Title'));
                         if (thumbFileTitle != null & thumbFileTitle != '') {
                            newLocalCourse.scormanywhere__Thumbnail_Path__c = newLocalCourse.scormanywhere__Thumbnail_Path__c + '?thumbName='+thumbFileTitle + '&uploadId=' + uploadId;
                         }

                       docIds.add((String)contentVersions.get(thumbId).get('ContentDocumentId'));
                   }
               }

                // *** Note to the Salesforce security team
                //We do not want regular users to have direct access to the Course object via CRUD/FLS settings
                //to allow a regular user to create new course.
                //This includes regular users, community user.

               insert newLocalCourse;
               shareFile(docIds);
               return newLocalCourse.id;
           }
           return null;
        } catch (System.QueryException sQE) {
            return sQE.getMessage();
        }
        return null;
    }

    @AuraEnabled
    public static void shareFile(List<String> docIds) {
        try {
            List<ContentDocumentLink> contDocLinks = new List<ContentDocumentLink>();
            if(!docIds.isEmpty()){
                for(String item : docIds){
                    if( String.isNotBlank(item)){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = item;
                        cdl.LinkedEntityId = UserInfo.getOrganizationId();
                        cdl.ShareType = 'V';
                        contDocLinks.add(cdl);
                    }
                }
            }
            if(!contDocLinks.isEmpty()){
                // *** Note to the Salesforce security team
                //We do not want regular users to have direct access to the ContentDocumentLink object via CRUD/FLS settings
                //to allow a regular user to create new ContentDocumentLink.
                //This includes regular users, community user.
                insert contDocLinks;
            }
        } catch (System.QueryException sQE) {
            System.debug('Error create ContentDocumentLink - ' + sQE.getMessage());
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

    @AuraEnabled
    public static String getPrefix() {
        System.debug('Site.getPathPrefix() - ' + Site.getPathPrefix());
        return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
    }

    @AuraEnabled
    public static String getSiteDomen() {
        System.debug('URL.getSalesforceBaseUrl().getHost() - ' + URL.getSalesforceBaseUrl().getHost());
        return URL.getSalesforceBaseUrl().getHost();
    }
    @AuraEnabled
    public static String getSessionId() {
        System.debug('UserInfo.getSessionId() - ' + UserInfo.getSessionId());
        return UserInfo.getSessionId();
    }

    public String networkId{
        get{
            return Network.getNetworkId();
        }
        set;}

    public String prefix{
        get{
            return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
        }
        set;}
}