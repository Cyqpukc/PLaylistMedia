global with sharing class MediaUploaderCtrltest {

    public String urlForUpload {get; set;}
    public String urlForGetStatus {get; set;}
    public String urlForCheckFile {get; set;}
    public String urlForGetProgress {get; set;}
    public String guid {get; set;}
    public String orgId {get; set;}
    public Boolean isUploadMediaAccessible {get; set;}

    public void init(){
        if(!Test.isRunningTest()){
            urlForUpload = scormanywhere.ApiService.getLink('UploadApi', '{"domain":"https://test-services.appinium.com/1.116"}');
            urlForGetProgress = scormanywhere.ApiService.getLink('GetProgress', '{"domain":"https://test-services.appinium.com/1.116"}');
            urlForGetStatus = scormanywhere.ApiService.getLink('GetStatus', '{"domain":"https://test-services.appinium.com/1.116"}');
            urlForCheckFile = scormanywhere.ApiService.getLink('CheckFile', '{"domain":"https://test-services.appinium.com/1.116"}');
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
    // *** Note to the Salesforce security team
    //We do not check FLS settings for the scormanywhere__Related_Media__c and scormanywhere__Course__c objects.
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
        scormanywhere__Related_Media__c newRMedia = new scormanywhere__Related_Media__c();
        newRMedia.scormanywhere__Course__c = courseId;
        newRMedia.scormanywhere__Object_Id__c = recordId;
        newRMedia.scormanywhere__Object_API_Name__c = recordId.getSObjectType().getDescribe().getName();
        Database.SaveResult result = Database.insert(newRMedia);
        System.debug('result - ' + result);
    }

    @AuraEnabled
    public static Boolean uploadToSF() {
        Set<String> fieldsName = new Set<String>{'Enable_External_Content__c','Enable_Salesforce_Content__c'};
        Map<String, Object> settingContent = Util.getDynamicCustomSettings('Scorm_Engine__c', fieldsName);
        if(!settingContent.isEmpty()){
            Boolean enableExternalContent = (settingContent != null && (Boolean)settingContent.get('Enable_External_Content__c'));
            Boolean enableSalesforceContent = (settingContent != null && (Boolean)settingContent.get('Enable_Salesforce_Content__c'));
            if(!enableExternalContent && enableSalesforceContent){
                return true;
            }
        }

        return false;
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
    public static Boolean updateMedia(scormanywhere__Course__c course) {
        try {
            System.debug('course - ' + course);
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
        try {
            Map<String, Object> mapParams = new Map<String, Object>();
            try {
                system.debug('jsonString: '+jsonString);
                mapParams = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                system.debug('mapParams : '+mapParams);
                docId = String.escapeSingleQuotes(String.valueOf(mapParams.get('videoContentVersionId')));
                domain = String.escapeSingleQuotes(String.valueOf(mapParams.get('domain')));
                duration = String.escapeSingleQuotes(String.valueOf(mapParams.get('duration')));
            } catch (Exception e) {
                docId = jsonString;
            }
            try{
                thumbId = String.escapeSingleQuotes(String.valueOf(mapParams.get('thumbVersionId')));
            } catch (Exception e){}

            List<String> verDocIds = new List<String>();
            verDocIds.add(docId);
            if(!String.isBlank(thumbId)){
                verDocIds.add(thumbId);
            }
            Map<Id, SObject> contentVersions = new Map<Id, SObject> (Database.query('SELECT Id, Title, FileType, Description, VersionNumber, PublishStatus, ContentSize, ContentDocumentId FROM ContentVersion WHERE Id IN :verDocIds'));
            if(contentVersions.containsKey(docId)){
               scormanywhere__Course__c newLocalCourse = new scormanywhere__Course__c(
                   scormanywhere__Description__c = (String)contentVersions.get(docId).get('Description'),
                   scormanywhere__SCORM_Training_Path__c = 'sfdclocal://'+(String)contentVersions.get(docId).get('Id'),
                   scormanywhere__SCORM_Training_Type__c = (String)contentVersions.get(docId).get('FileType'),
                   scormanywhere__SCORM_Title__c = (String)contentVersions.get(docId).get('Title'),
                   scormanywhere__SCORM_File_Size__c = (Decimal)contentVersions.get(docId).get('ContentSize'),
                   scormanywhere__Duration__c = String.isBlank(duration) ? '' : duration + ' sec',
                   scormanywhere__Status__c = 'Active',
                   Name = getSymbolsText((String)contentVersions.get(docId).get('Title'), 80)
               );
               list<String> docIds = new List<String>();
               docIds.add((String)contentVersions.get(docId).get('ContentDocumentId'));
               if (!String.isBlank(thumbId)) {
                   newLocalCourse.scormanywhere__Thumbnail_Path__c = '/sfc/servlet.shepherd/version/download/'+thumbId;
                   if(contentVersions.containsKey(thumbId)){
                       docIds.add((String)contentVersions.get(thumbId).get('ContentDocumentId'));
                   }
               }
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