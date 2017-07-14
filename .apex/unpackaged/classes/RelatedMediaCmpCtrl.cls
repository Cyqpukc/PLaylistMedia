public with sharing class RelatedMediaCmpCtrl {

    @AuraEnabled
    public static List<MediaWrapper> getContent(String parentId) {

	    List<scormanywhere__Related_Media__c> relatedMedia = new List<scormanywhere__Related_Media__c>();
	    
    	if(Util.isObject('scormanywhere__Related_Media__c', Util.IS_ACCESSIBLE)
    		&& Util.isField('scormanywhere__Related_Media__c', 'Name,scormanywhere__Course__c,scormanywhere__Object_Id__c', Util.IS_ACCESSIBLE)) {
				// *** Note to the Salesforce security team
				//Courses are private, guest and community users
				//have to have access to some courses, their access to those course is controlled by the application logic. 
				//That’s why we use ‘without sharing’ here.
				relatedMedia= WithoutSharingController.getRelatedMedia(parentId);
    	}
    	
        Set<String> coursesId = new Set<String>();
        for(scormanywhere__Related_Media__c item : relatedMedia){
            coursesId.add(item.scormanywhere__Course__c);
        }

        Map<String, Decimal> courseId_progress = new Map<String, Decimal>();
		
    	if(Util.isObject('scormanywhere__Transcript__c', Util.IS_ACCESSIBLE)
    		&& Util.isField('scormanywhere__Transcript__c', 'scormanywhere__Progress__c', Util.IS_ACCESSIBLE)) {
			// *** Note to the Salesforce security team
			//Transcript are private, guest and community users
			//have to have access to some Transcript, their access to those Transcript is controlled by the application logic. 
			//That’s why we use ‘without sharing’ here.    			
	        for(scormanywhere__Transcript__c transcript : WithoutSharingController.getMyTranscripts()){
	            courseId_progress.put(transcript.scormanywhere__Course__c, transcript.scormanywhere__Progress__c);
	        }
    	}
        List<MediaWrapper> result = new List<MediaWrapper>();
        for (scormanywhere__Related_Media__c item : relatedMedia) {
            if(courseId_progress.containsKey(item.scormanywhere__Course__c)){
                result.add(new MediaWrapper(item, courseId_progress.get(item.scormanywhere__Course__c)));
            } else {
                result.add(new MediaWrapper(item, null));
            }
        }
        return result;
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
}