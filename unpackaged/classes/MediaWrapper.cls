public with sharing class MediaWrapper {

    @AuraEnabled public List<ChannelWrapper> allChannels {get; set;}
    @AuraEnabled public List<String> channels {get; set;}
    @AuraEnabled public String backImage {get; set;}
    @AuraEnabled public String color {get; set;}
    @AuraEnabled public String discription {get; set;}
    @AuraEnabled public String discriptionMedium {get; set;}
    @AuraEnabled public String discriptionSmall {get; set;}
    @AuraEnabled public String id {get; set;}
    @AuraEnabled public String link {get; set;}
    @AuraEnabled public String name {get; set;}
    @AuraEnabled public String relatedMediaId {get; set;}
    @AuraEnabled public String uploadDate {get; set;}
    @AuraEnabled public Integer progress {get; set;}
    @AuraEnabled public String transcriptId {get; set;}

    @AuraEnabled public String linkProfile {get; set;}
    @AuraEnabled public String linkCourse {get; set;}
    @AuraEnabled public String userName {get; set;}

    public MediaWrapper() {
    }

    public MediaWrapper(scormanywhere__Course__c course) {
        link = getlinkCourse(course.Id);
        linkProfile = '/' + course.OwnerId;
        backImage = getBckgImg(course);
        linkCourse = '/course/' + course.Id;
        id = course.Id;
        name = course.Name.replace('_', ' ');
        uploadDate = course.CreatedDate.format();
        userName = course.Owner.Name;
        progress=0;
        if(!course.scormanywhere__Transcripts__r.isEmpty()){
            if(course.scormanywhere__Transcripts__r[0].scormanywhere__Progress__c != null){
                progress = Integer.valueOf(course.scormanywhere__Transcripts__r[0].scormanywhere__Progress__c);
            }
        }
    }

	private String getBckgImg(scormanywhere__Course__c course) {
        String backImage = '';
        if(String.isNotBlank(Network.getNetworkId())){
            backImage = (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
        }
        if(String.isNotBlank(course.scormanywhere__Thumbnail_Path__c)){
            if(course.scormanywhere__Thumbnail_Path__c.indexOf('http') != 0){
                backImage += String.escapeSingleQuotes(course.scormanywhere__Thumbnail_Path__c);
            } else{
		    	if (course.scormanywhere__SCORM_Training_Type__c != null && course.scormanywhere__SCORM_Training_Type__c.toLowerCase() == 'mp3') {
		    		backImage = Site.getPathPrefix()+'/resource/vtui__Components_Library/img/biga.png';
		    		backImage = backImage.replace('/s', '');
		    	} else {
		        	backImage = String.escapeSingleQuotes(course.scormanywhere__Thumbnail_Path__c);
		    	}
            }
        } else{
	    	if (course.scormanywhere__SCORM_Training_Type__c != null && course.scormanywhere__SCORM_Training_Type__c.toLowerCase() == 'mp3') {
	    		backImage = Site.getPathPrefix()+'/resource/vtui__Components_Library/img/biga.png';
	    		backImage = backImage.replace('/s', '');
	    	} else {
                backImage = null;
            }
        }
    	return backImage;
	}
    private String getlinkCourse(String courseId){
        String link;
        if(String.isNotBlank(Network.getNetworkId())){
            String temp = Network.getLoginUrl(Network.getNetworkId());
            link = temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/').removeEnd('/s');
        } else {
            link = '/apex';
        }
        link += '/scormanywhere__SCORM_Player?inline=1&courseId=' + courseId;
        return link;
    }
    public MediaWrapper(scormanywhere__Course__c course, List<ChannelWrapper> channelWrappers) {
        this(course);

        channels = new List<String>();
        allChannels = new List<ChannelWrapper>();
        for (ChannelWrapper cw : channelWrappers) {
            ChannelWrapper newCW = new ChannelWrapper(cw);
            newCW.containsVideo = false;
            allChannels.add(newCW);
        }
        for(scormanywhere__Channel_Course__c item : course.scormanywhere__Courses__r){
            channels.add(item.scormanywhere__Channel__c);
            for (ChannelWrapper cw : allChannels) {
                System.debug(item.scormanywhere__Channel__c);
                System.debug(cw.Id);
                if (cw.Id == item.scormanywhere__Channel__c) {
                    cw.containsVideo = true;
                    break;
                }
            }
        }
        progress=0;
    }
    public MediaWrapper(scormanywhere__Transcript__c transcript) {
        System.debug(Network.getLoginUrl(Network.getNetworkId()));
        String temp = Network.getLoginUrl(Network.getNetworkId());
        link = getlinkCourse(transcript.Id);
		backImage = getBckgImg(transcript.scormanywhere__course__r);

        linkProfile = '/' + transcript.scormanywhere__Course__r.OwnerId;
        linkCourse = '/course/' + transcript.scormanywhere__Course__c;
        discription = transcript.scormanywhere__course__r.scormanywhere__Description__c;
        if(!String.isBlank(discription)){
            discription = discription.replace('_', ' ');
            if(discription.length() > 150){
                discriptionMedium = discription.substring(0, 147) + '... ';
            }
            if(discription.length() > 90){
                discriptionSmall = discription.substring(0, 87) + '... ';
            }
        }
        transcriptId = transcript.Id;
        id = transcript.scormanywhere__course__c;
        name = transcript.scormanywhere__course__r.Name.replace('_', ' ');
        uploadDate = transcript.scormanywhere__course__r.CreatedDate.format();
        userName = transcript.scormanywhere__Course__r.Owner.Name;
        progress = transcript.scormanywhere__Progress__c == null ? 0 : Integer.valueOf(transcript.scormanywhere__Progress__c);

        if(progress < 25){
            color = '#DE555B';
        } else {
            if(progress == 100){
                color = '#4bca81';
            } else {
                color = '#0070d2';
            }
        }
    }

    public MediaWrapper(scormanywhere__Related_Media__c rMedia, Decimal transcriptProgress) {
        id = rMedia.scormanywhere__Course__c;
        link = getlinkCourse(rMedia.scormanywhere__Course__c);
        backImage = getBckgImg(rMedia.scormanywhere__Course__r);

        name = rMedia.scormanywhere__Course__r.Name.replace('_', ' ');
        relatedMediaId = rMedia.Id;
        progress=0;
        if(transcriptProgress != null){
            progress = Integer.valueOf(transcriptProgress);
        }
    }
}