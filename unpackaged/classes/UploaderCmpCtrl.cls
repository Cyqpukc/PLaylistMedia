public class UploaderCmpCtrl {
    @AuraEnabled
    public static UploladParams getUploadParams(){
        UploladParams result = new UploladParams();
        if(!Test.isRunningTest()){
            result.urlForUpload = scormanywhere.ApiService.getLink('UploadApi', null);
            result.urlForGetProgress = scormanywhere.ApiService.getLink('GetProgress', null);
            result.urlForGetStatus = scormanywhere.ApiService.getLink('GetStatus', null);
        } else{
            result.urlForUpload = 'testurl&uploadId=124-234-234&testparam=11111';
            result.urlForGetProgress = 'testprogress';
            result.urlForGetStatus = 'teststatus';
        }
        result.guid = getStringParameterFromURL('uploadId', result.urlForUpload);
        result.guid = result.guid.toLowerCase();
        result.orgId = UserInfo.getOrganizationId();
        result.isUploadMediaAccessible = checkMediaAccess();
        system.debug(result);
        return result;
    }
    
    private static Boolean checkMediaAccess() {
        return scormanywhere__Related_Media__c.sObjectType.getDescribe().isCreateable()
            && scormanywhere__Course__c.sObjectType.getDescribe().isCreateable();
    }
    
    private static String getStringParameterFromURL(String parameterName, String stringUrl) {
        if(!String.isBlank(stringUrl)){
            Map<String, String> paramsByName = new Map<String, String>();
            for(String item : stringUrl.split('&')){
                paramsByName.put(item.substringBefore('='), item.substringAfter('='));
            }
            return paramsByName.get(parameterName);
        }
        return null;
    }
    
    public class UploladParams{
        @AuraEnabled String urlForUpload {get; set;}
        @AuraEnabled String urlForGetProgress {get; set;}
        @AuraEnabled String urlForGetStatus {get; set;}
        @AuraEnabled String orgId {get; set;}
        @AuraEnabled String guid {get; set;}
        @AuraEnabled Boolean isUploadMediaAccessible {get; set;}
    }
}