public with sharing class Util {

    public static final String OBJECT_APINAME_COURSE = 'scormanywhere__Course__c';
    public static final String REFERENCE_TYPE = 'REFERENCE';
    public static final String ARTICLE_THUMB_UP_TYPE = 'Up';
    public static final String ARTICLE_THUMB_DOWN_TYPE = 'Down';
    public static final String DATE_TYPE = 'DATE';
    public static final String DATETIME_TYPE = 'DATETIME';
    public static final String FILE_TYPE = 'FILE';
    public static final String FILE_TEMPLATE = '{0}servlet/fileField?entityId={1}&field={2}';
    public static final String TOPIC_TEMPLATE = '{0}s/topic/{1}/{2}?tabset-dc8fe=2';
    public static final String TEXTAREA_LONG_TYPE = 'TEXTAREALONG';
    public static final String TEXTAREA_TYPE = 'TEXTAREA';
    public static final String GUEST_TYPE = 'Guest';

    public static String getDomainForChatterLink() {
        try {
            String externalServiceValue = scormanywhere__ViewTrac_Settings__c.getOrgDefaults().scormanywhere__External_Service__c;
            if (String.isNotBlank(externalServiceValue)) {
                List<String> externalServiceValues = externalServiceValue.split(',');
                if(externalServiceValues.size() >2 && String.isNotBlank(externalServiceValues[2])){
                    return externalServiceValues[2];
                }
            }
        } catch (system.exception e) {        }
        return null;
    }

    public static Boolean isObjectFieldAccessibility(String objectApiName, String fieldsName){
        if(String.isBlank(objectApiName)){
            return false;
        }
        String prefixResult = getOrgPrefix();
        objectApiName = objectApiName.split('__').size() == 2 ? prefixResult+objectApiName : objectApiName;
        Map<String, Schema.SObjectType> globalSchema = Schema.getGlobalDescribe();
        Schema.SObjectType objType = globalSchema.get(objectApiName);
        if(objType != null){
            Schema.DescribeSObjectResult obj = objType.getDescribe();
            if(!String.isBlank(fieldsName)){
                List<String> objectFields = fieldsName.replace(' ','').split(',');
                Map<String, Schema.SObjectField> mapData = obj.fields.getMap();
                for(String fld : objectFields){
                    fld = fld.split('__').size() == 2 ? prefixResult+fld : fld;
                    if(!mapData.containsKey(fld)){
                        return false;
                    }
                }
            }else{
                return false;
            }
        } else {
            return false;
        }
        return true;
    }

    public static String getOrgPrefix(){
        Organization sfOrg = [SELECT Id, IsSandbox, NamespacePrefix FROM Organization LIMIT 1];
        String prefixResult = sfOrg.NamespacePrefix;
        return prefixResult != null ? prefixResult + '__' : '';
    }

    public static Object getDynamicCustomSetting(String customSettingApiName, String fieldApiName) {
        Object result;
        Map<String, Object> cs = getDynamicCustomSettings(customSettingApiName, new Set<String>{fieldApiName});
        if (cs.containsKey(fieldApiName)) {
            result = cs.get(fieldApiName);
        }
        return result;
    }

    public static Map<String, Object> getDynamicCustomSettings(String customSettingApiName, Set<String> fieldApiNames) {
        Map<String, Object> result = new Map<String, Object>();

        String prefixResult = getOrgPrefix();

        try{
            String query = 'SELECT ';
            for (String fieldApiName : fieldApiNames) {
                query += prefixResult + fieldApiName + ',';
            }
            query = query.removeEnd(',') + ' FROM ' + customSettingApiName + ' LIMIT 1';
            //Do not check crud\fls for custom settings objects
            List<sObject> results = WithoutSharingController.getDynamicQuery(query);
            if(results != null && !results.isEmpty()){
                for (String fieldApiName : fieldApiNames) {
                    Object cs = results.get(0).get(prefixResult + fieldApiName);
                    result.put(fieldApiName, cs);
                }
            }
        } catch (Exception e){
             System.debug('e - ' + e);
        }
        return result;
    }

    public static String createEmbeddedLink(String courseId, String currentUrl){
        String temp = Network.getLoginUrl(Network.getNetworkId());
        if (temp != null) {
            String forceComDomain = getStandardDomain();
            temp = String.isNotBlank(forceComDomain) ? forceComDomain : currentUrl;
            temp = 'https://' + temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/').removeEnd('/s');
        } else{
            temp = 'https://' + currentUrl;
        }

        String result = '<iframe allowfullscreen="true" mozallowfullscreen="true" frameborder="0" scrolling="no" src="' +
        temp + '/apex/scormanywhere__SCORM_Player?inline=1&article=1&courseId=' + courseId + '"></iframe>';
        return result;
    }

    private static String getStandardDomain(){
        List<DomainSite> domainSite = [SELECT Id, Domain.Domain, DomainId, SiteId, PathPrefix
                                        FROM DomainSite
                                        WHERE SiteId = :Site.getSiteId()
                                        AND DomainId != null
                                        AND Domain.Domain != null];
        if(!domainSite.isEmpty()){
            for(DomainSite item : domainSite){
                if(item.Domain.Domain.endsWith('.force.com')){
                    return item.Domain.Domain + item.PathPrefix;
                }
            }
        }
        return null;
    }

    public static void addMediaToChannel(String channelId, String mediaId, String channelName){
        scormanywhere__Channel_Course__c newRecord = new scormanywhere__Channel_Course__c();
        List<scormanywhere__Channel_Course__c> courseChannel;
        if(!String.isBlank(channelName)){
            scormanywhere__Channel__c targetChannel;

            if(Util.isObject('scormanywhere__Channel__c', Util.IS_CREATEABLE) &&
            Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
            Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_ACCESSIBLE) &&
            Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {

	            List<scormanywhere__Channel__c> existChannels = [SELECT Id
	                                                FROM scormanywhere__Channel__c
	                                                WHERE scormanywhere__Title__c = :channelName
	                                                AND CreatedById = : UserInfo.getUserId()
	                                                LIMIT 1];
	            if (existChannels != null && !existChannels.isEmpty()) {
	                targetChannel = existChannels[0];
	            } else {
	                targetChannel = new scormanywhere__Channel__c();
	                targetChannel.scormanywhere__Title__c = channelName;
	                insert targetChannel;
	            }
            }
            if(Util.isObject('scormanywhere__Channel_Course__c', Util.IS_CREATEABLE) &&
            	Util.isObject('scormanywhere__Channel_Course__c', Util.IS_ACCESSIBLE) &&
            	Util.isField('scormanywhere__Channel_Course__c', 'scormanywhere__Course__c,scormanywhere__Channel__c', Util.IS_ACCESSIBLE)) {
				// *** Note to the Salesforce security team
				//Course are private, guest and community users
				//have to have access to some Course, their access to those Course is controlled by the application logic.
				//That’s why we use ‘without sharing’ here.
	            List<scormanywhere__Channel_Course__c> existCourseChannels = WithoutSharingController.getChannelCourses(mediaId, String.valueOf(targetChannel.Id));

	            if (existCourseChannels.isEmpty()) {
	                newRecord.scormanywhere__Channel__c = targetChannel.Id;
	                newRecord.scormanywhere__Course__c = mediaId;
	                // *** Note to the Salesforce security team
					//Course are private, guest and community users
					//have to have access to some Course, their access to those Course is controlled by the application logic.
					//That’s why we use ‘without sharing’ here.
	                //insert without sharing, cause guest, community and regular user have no access to create or edit Course__c

		            List<scormanywhere__Channel_Course__c> ChannelCourses = new List<scormanywhere__Channel_Course__c>();
		            ChannelCourses.add(newRecord);
		            WithoutSharingController.insertChannelCourses(ChannelCourses);
	            }

            }
        } else{
            if(Util.isObject('scormanywhere__Channel_Course__c', Util.IS_CREATEABLE) &&
            	Util.isObject('scormanywhere__Channel_Course__c', Util.IS_DELETABLE) &&
            	Util.isObject('scormanywhere__Channel_Course__c', Util.IS_ACCESSIBLE) &&
            	Util.isField('scormanywhere__Channel_Course__c', 'scormanywhere__Course__c,scormanywhere__Channel__c', Util.IS_ACCESSIBLE)) {
                // *** Note to the Salesforce security team
				//Course are private, guest and community users
				//have to have access to some Course, their access to those Course is controlled by the application logic.
				//That’s why we use ‘without sharing’ here.
            	List<scormanywhere__Channel_Course__c> existCourseChannels = WithoutSharingController.getChannelCourses(mediaId, channelId);

	            if (!existCourseChannels.isEmpty()) {
	            	WithoutSharingController.deleteChannelCourseRecords(existCourseChannels);
	            } else {
	                newRecord.scormanywhere__Channel__c = channelId;

	                courseChannel = WithoutSharingController.getChannelCourses(mediaId, channelId);

	                newRecord.scormanywhere__Course__c = mediaId;
	                if(courseChannel.isEmpty()){
		                //insert without sharing, cause guest, community and regular user have no access to create or edit
			            List<scormanywhere__Channel_Course__c> ChannelCourses = new List<scormanywhere__Channel_Course__c>();
			            ChannelCourses.add(newRecord);
		                // *** Note to the Salesforce security team
						//Course are private, guest and community users
						//have to have access to some Course, their access to those Course is controlled by the application logic.
						//That’s why we use ‘without sharing’ here.
			            WithoutSharingController.insertChannelCourses(ChannelCourses);
	                }
	            }
            }
        }
    }

    public static Boolean sendMediaLink(String contentId, String emailTo){
        List<String> emails = new List<String>();
        for(String sEmail : emailTo.split(',')) {
            emails.add(sEmail.trim());
        }
        scormanywhere__Course__c content= new scormanywhere__Course__c();
		if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
        	Util.isField(Util.OBJECT_APINAME_COURSE, 'Name',Util.IS_ACCESSIBLE)) {
        	WithoutSharingController.getSingleCourse(contentId);
        	content = WithoutSharingController.getSingleCourse(contentId);
        }
        Messaging.SingleEmailMessage shareEmail = new Messaging.SingleEmailMessage();
        String communityPrefix;
        try {
            communityPrefix = Site.getPathPrefix();
        } catch (Exception e) {
            communityPrefix = '';
        }
        String contentUrl = URL.getSalesforceBaseUrl().toExternalForm() + communityPrefix;
        String temp = Network.getLoginUrl(Network.getNetworkId());
        if (temp != null) {
            contentUrl += '/course';
        }
        contentUrl += '/' + content.Id;
        String userFirstName = String.isNotBlank(UserInfo.getFirstName()) ? UserInfo.getFirstName() : '';
        String userLastName = String.isNotBlank(UserInfo.getLastName()) ? UserInfo.getLastName() : '';
        String emailSubject = userFirstName + ' ' + userLastName + ' has shared a Media with you';
        String emailBody = userFirstName + ' ' + userLastName + ' shared the following Media with you:<br/><br/>'
            + '<a href="' + contentUrl + '" style="font-size:larger;color:#408AD2">'
            + content.Name + '</a><br/><br/>'
            + '<a href="' + contentUrl + '" style="background-color:#408AD2;border:2px solid #679ED2;border-radius:5px;color:#ffffff;display:inline-block;'
                    +'font-family:sans-serif;font-size:large;line-height:44px;text-align:center;font-weight:500;text-decoration:none;width:170px;'
                    +'-webkit-text-size-adjust:none;mso-hide:all;">Open</a><br/><br/>';
        shareEmail.setSubject(emailSubject);
        shareEmail.setHtmlBody(emailBody);
        shareEmail.setSaveAsActivity(false);
        shareEmail.setToAddresses(emails);
        shareEmail.setCharset('UTF-8');
        System.debug(shareEmail);
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{shareEmail},false);
            return true;
        } catch (Exception e){
            System.debug(e);
            return false;
        }
    }

    public static Boolean sendMediaLink(String contentId, String emailTo, String domain, String autoplay){
        List<String> emails = new List<String>();
        for(String sEmail : emailTo.split(',')) {
            emails.add(sEmail.trim());
        }
        scormanywhere__Course__c content= new scormanywhere__Course__c();
		if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
        	Util.isField(Util.OBJECT_APINAME_COURSE, 'Name',Util.IS_ACCESSIBLE)) {
        	WithoutSharingController.getSingleCourse(contentId);
        	content = WithoutSharingController.getSingleCourse(contentId);
        }
        Messaging.SingleEmailMessage shareEmail = new Messaging.SingleEmailMessage();
        String fullLink = domain + '#Id=' + content.Id+'&'+autoplay;
        String userFirstName = String.isNotBlank(UserInfo.getFirstName()) ? UserInfo.getFirstName() : '';
        String userLastName = String.isNotBlank(UserInfo.getLastName()) ? UserInfo.getLastName() : '';
        String emailSubject = userFirstName + ' ' + userLastName + ' has shared a Media with you';
        String emailBody = userFirstName +' ' +  userLastName + ' shared the following Media with you:<br/><br/>'
            + '<a href="' + fullLink + '" style="font-size:larger;color:#408AD2">'
            + content.Name + '</a><br/><br/>'
            + '<a href="' + fullLink + '" style="background-color:#408AD2;border:2px solid #679ED2;border-radius:5px;color:#ffffff;display:inline-block;'
                    +'font-family:sans-serif;font-size:large;line-height:44px;text-align:center;font-weight:500;text-decoration:none;width:170px;'
                    +'-webkit-text-size-adjust:none;mso-hide:all;">Open</a><br/><br/>';
        shareEmail.setSubject(emailSubject);
        shareEmail.setHtmlBody(emailBody);
        shareEmail.setSaveAsActivity(false);
        shareEmail.setToAddresses(emails);
        shareEmail.setCharset('UTF-8');
        System.debug(shareEmail);
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{shareEmail},false);
            return true;
        } catch (Exception e){
            System.debug(e);
            return false;
        }
    }


    public static String getLink(String courseId){

        String link = '';
        scormanywhere__Course__c courseTemp = WithoutSharingController.getSingleCourse(courseId);
        if(courseTemp != null) {
            System.debug('create link');
            if(String.isNotBlank(Network.getNetworkId())){
                String temp = Network.getLoginUrl(Network.getNetworkId());
                link = temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/').removeEnd('/s');
            } else {
                link = '/apex';
            }
            link += '/scormanywhere__SCORM_Player?inline=1&courseId=' + courseTemp.Id;
        }
        return link;
    }

    public static final String IS_CREATEABLE = 'isCreateable';
    public static final String IS_ACCESSIBLE = 'isAccessible';
    public static final String IS_UPDATEABLE = 'isUpdateable';
    public static final String IS_DELETABLE = 'isDeletable';

    public class UtilException extends Exception{}

	public static Boolean isField(String objectName, String fieldsName, String isWhat) {
		Boolean returnValue = true;
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult r = targetType.getDescribe() ;
		String[] listFieldsName = fieldsName.split(',');
		for (String fieldName : listFieldsName) {
			fieldName = fieldName.trim();
			Map<String,Schema.SObjectField> fields = r.fields.getMap();
			system.debug('curent name: '+fieldName);
			system.debug('contains : '+fields.get(fieldName));
			Schema.DescribeFieldResult desribeResult = fields.get(fieldName.toLowerCase()).getDescribe();

			if (isWhat == IS_CREATEABLE) {
				returnValue = desribeResult.isCreateable();
				if (returnValue == false) {
					Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Create + ' '+fieldName+' ' + Label.Field);
				}
			}
			if (isWhat == IS_ACCESSIBLE) {
				returnValue = desribeResult.isAccessible();
				if (returnValue == false) {
					Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Access + ' '+fieldName+' ' + Label.Field);
				}
			}
			if (isWhat == IS_UPDATEABLE) {
				returnValue = desribeResult.isUpdateable();
				if (returnValue == false) {
					Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Update + ' '+fieldName+' ' + Label.Field);
				}
			}
			if (returnValue == false) {
				return returnValue;
			}
		}
		return returnValue;
	}

	public static Boolean isObject(String objectName, String isWhat) {
		Boolean returnValue = true;
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult r = targetType.getDescribe() ;

		if (isWhat == IS_CREATEABLE) {
			returnValue = r.isCreateable();
			if (returnValue == false) {
				Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Create + ' '+objectName+' ' + Label.Object);
			}
		}
		if (isWhat == IS_ACCESSIBLE) {
			returnValue = r.isAccessible();
			if (returnValue == false) {
				Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Access + ' '+objectName+' ' + Label.Object);
			}
		}
		if (isWhat == IS_UPDATEABLE) {
			returnValue = r.isUpdateable();
			if (returnValue == false) {
				Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Update + ' '+objectName+' ' + Label.Object);
			}
		}
		if (isWhat == IS_DELETABLE) {
			returnValue = r.isDeletable();
			if (returnValue == false) {
				Util.setPageErrorMessage(Label.No_Permissions_for + ' ' + Label.Delete + ' '+objectName+' ' + Label.Object);
			}
		}
		return returnValue;
	}

	public static void setPageErrorMessage(String message) {
		setPageOrExceptionMessage(ApexPages.Severity.ERROR, message);
	}

	public static void setPageOrExceptionMessage(ApexPages.Severity severity, String message, String methodName, String emailMessage) {
		String error = debugInfo(emailMessage, methodName, 'Fatal');
		sendEmail(error, Label.Internal_error_has_occured);
		setPageOrExceptionMessage(severity, message);
	}
	public static void setPageOrExceptionMessage(ApexPages.Severity severity, String message) {
		if(ApexPages.currentPage() != null){
			ApexPages.AddMessage(new ApexPages.Message(severity, message));
		} else {
			//If not page, show in debug make exception
			throw new Util.UtilException(message);
		}
	}
	public static String debugInfo(String originalException, String methodName, String typeException) {
		String error = '';
		error += '\nException: '+originalException;
		error += '\nOrganization Id: '+UserInfo.getOrganizationId();
		error += '\nOrganization Name: '+UserInfo.getOrganizationName();
		error += '\nUser Id: '+UserInfo.getUserId();
		error += '\nUserName: '+UserInfo.getUserName();
		error += '\nUser FirstName: '+UserInfo.getFirstName();
		error += '\nUser LastName: '+UserInfo.getLastName();
		error += '\nMethod Name: '+methodName;
		error += '\nType Exception: '+typeException;
		return error;
	}

	public static void sendEmail(String error, String subject) {
		try {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			list<String> emails = new list<String>();
			emails.add('dev@scormanywhere.com');
			email.setToAddresses(emails);
			email.setSubject(subject);
			error = error.replaceAll('\n','<br />');
			email.setHtmlBody(error);
			Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		} catch (Exception e) {
			//Email exception
		}
	}
    public static Set<Id> getAvailableCourseIds(List<scormanywhere__Course__c> courses) {
        Set<Id> availableCourseIds = new Set<Id>();
        Set<Id> mediaIds = new Set<Id>();
        for (scormanywhere__Course__c course : courses) {
            mediaIds.add(course.Id);
        }

        if (!mediaIds.isEmpty()) {
            List<scormanywhere__Course__c> availableCourses = [SELECT Id FROM scormanywhere__Course__c WHERE Id IN :mediaIds];
            for (scormanywhere__Course__c courseItem : availableCourses) {
                availableCourseIds.add(courseItem.Id);
            }
        }

        return availableCourseIds;
    }

    public static Set<Id> getAvailableCourseIds(List<scormanywhere__Transcript__c> transcripts) {
        Set<Id> availableCourseIds = new Set<Id>();
        Set<Id> mediaIds = new Set<Id>();
        for (scormanywhere__Transcript__c transcript : transcripts) {
            mediaIds.add(transcript.scormanywhere__Course__c);
        }

        if (!mediaIds.isEmpty()) {
            List<scormanywhere__Course__c> availableCourses = [SELECT Id FROM scormanywhere__Course__c WHERE Id IN :mediaIds];
            for (scormanywhere__Course__c courseItem : availableCourses) {
                availableCourseIds.add(courseItem.Id);
            }
        }

        return availableCourseIds;
    }
    public static final Set<String> WHAT_ID_OBJECTS = new Set<String> {
        'Account',
        'Asset',
        'Campaign',
        'Case',
        'Contract',
        'Opportunity',
        'Order',
        'Product',
        'Solution'
    };

    public static Boolean isValidWhatId(String whatIdString) {
        Boolean isValid = false;
        try {
            Id whatId = (Id) whatIdString;
            isValid = isValidWhatId(whatId);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        return isValid;
    }

    public static Boolean isValidWhatId(Id whatId) {
        Boolean isValid = false;
        try {
            for (String whatIdObject : WHAT_ID_OBJECTS) {
                if (whatIdObject == whatId.getSObjectType().getDescribe().getName()) {
                    isValid = true;
                    break;
                }
            }
            //if custom object
            if (whatId.getSObjectType().getDescribe().getName().endsWith('__c')) {
                isValid = true;
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        return isValid;
    }

    public static String getPublicLinkNewWindow(String myCourseId, String siteId) {
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        scormanywhere__Course__c courses = WithoutSharingController.getSingleCourse(myCourseId);
        if(courses != null && !courses.scormanywhere__Public__c){
           return Label.MediaNotPublic;
        }
        PageReference pr = Page.getPublicLink;
        pr.getParameters().put('mediaId', myCourseId);
        pr.getParameters().put('siteId', siteId);

        String link = '';
        if (!Test.isRunningTest()) {
            system.debug(pr.getContent().toString());
            link = pr.getContent().toString();
        }

        return link;
    }

    public static String getPublicLinkAp(String myCourseId, String siteId, String domain, String autoplay) {
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        scormanywhere__Course__c courses = WithoutSharingController.getSingleCourse(myCourseId);
        if(courses != null && !courses.scormanywhere__Public__c){
           return Label.MediaNotPublic;
        }
        String rValue = domain;
        if(domain.indexOf('one.app') == -1){
            rValue +='#';
        } else{
            rValue +='?';
        }
        rValue += 'Id=' + myCourseId+'&'+autoplay;
        return rValue;
    }

    public static List<Id> getCourseIdsForChannel(String channelId) {
        Set<Id> courseIds = new Set<Id>();
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.

        if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE) &&
           Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
           Util.isObject('scormanywhere__Channel_Course__c', Util.IS_ACCESSIBLE) &&
           Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c',Util.IS_ACCESSIBLE) &&
            Util.isField('scormanywhere__Channel_Course__c', 'scormanywhere__Channel__c,scormanywhere__Course__c',Util.IS_ACCESSIBLE)) {

            scormanywhere__Channel__c channels = WithoutSharingController.getChannelWithCourseIds(channelId);

            for(scormanywhere__Channel_Course__c item : channels.scormanywhere__Channels__r){
                courseIds.add(item.scormanywhere__Course__c);
            }
        }
        return new List<Id>(courseIds);
    }

    public static List<Id> getCourseIdsForCatalog(String catalogId) {
        Set<Id> courseIds = new Set<Id>();

        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
            Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
            //without crud\fls and without sharing user must see any catalog
            // *** Note to the Salesforce security team
            //We do not want regular users to have direct access to the scormanywhere__Course_Catalog__c object via CRUD/FLS settings

            // *** Note to the Salesforce security team
            //Catalogs are private, guest and community users
            //have to have access to some Catalogs, their access to those Catalog is controlled by the application logic.
            //That’s why we use ‘without sharing’ here.

            scormanywhere__Catalog__c catalogs = WithoutSharingController.getCatalogWithCourseIds(catalogId);
            for(scormanywhere__Course_Catalog__c item : catalogs.scormanywhere__Course_Catalogs__r){
                if(!String.isBlank(item.scormanywhere__Course__c)){
                    courseIds.add(item.scormanywhere__Course__c);
                }
            }
        }

        return new List<Id>(courseIds);
    }

    public static String getCourseTranscriptsSOQL(){
        String result = 'SELECT Id, Name, scormanywhere__Thumbnail_Path__c, scormanywhere__SCORM_Training_Type__c, scormanywhere__Description__c, CreatedDate, OwnerId, Owner.Name, (SELECT Id, scormanywhere__Progress__c, scormanywhere__User__c FROM scormanywhere__Transcripts__r WHERE scormanywhere__User__c = \'';
        result += UserInfo.getUserId() + '\'';
        if(Util.isObjectFieldAccessibility('scormanywhere__Transcript__c', 'rwscorm__Learning_Assignment__c')) {
            result += ' AND rwscorm__Learning_Assignment__c = null ';
        }
        result +='AND scormanywhere__Test_Launch__c = false)  FROM scormanywhere__Course__c ';
        return result;
    }
}