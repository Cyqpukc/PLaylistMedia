public class MultimediaListCmpCtrl {
	
    @AuraEnabled
    public static List<MMediaWrapper> getMultimedia() {
        List<MMediaWrapper> result = new List<MMediaWrapper>();
        List<scormanywhere__Related_Media__c> relatedMedias = [
                    SELECT Id, Name, scormanywhere__Course__c, scormanywhere__Object_Id__c
                    FROM scormanywhere__Related_Media__c
                    WHERE scormanywhere__Course__c != null
                        AND scormanywhere__Object_API_Name__c = 'multM__c'
                    ORDER BY CreatedDate DESC];
        List<multM__c> mMedias = [SELECT Id, Name FROM multM__c ORDER BY CreatedDate DESC];
        for(multM__c item : mMedias){
            List<String> coursesId = new List<String>();
            for(scormanywhere__Related_Media__c rm : relatedMedias){
                if(rm.scormanywhere__Object_Id__c == item.Id){
                    coursesId.add(rm.scormanywhere__Course__c);
                }
            }
            result.add(new MMediaWrapper(item, coursesId));
        }
        return result;
        //return [SELECT Id, Name FROM multM__c];
    }
	
    @AuraEnabled
    public static String getMedia(String multiMediaId) {
        String searchId = '%' + multiMediaId +'%';
        List<scormanywhere__Related_Media__c> relatedMedias = [
                    SELECT Id, Name, scormanywhere__Course__c
                    FROM scormanywhere__Related_Media__c
                    WHERE scormanywhere__Course__c != null
                        AND scormanywhere__Object_Id__c LIKE : searchId
                    ORDER BY CreatedDate DESC];
        if(!relatedMedias.isEmpty()){
            return relatedMedias[0].scormanywhere__Course__c;
        }
        return null;
    }
    
    public class MMediaWrapper{
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public List<String> mediaId {get; set;}
        
        public MMediaWrapper(multM__c mMedia, List<String> mediaId){
            this.id = mMedia.Id;
            this.Name = mMedia.Name;
            this.mediaId = new List<String>();
            this.mediaId.addAll(mediaId);
        }
    }
}