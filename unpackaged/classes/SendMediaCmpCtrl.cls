public with sharing class SendMediaCmpCtrl {

    @AuraEnabled
    public static List<TemplateWrapper> getTemplates() {
        List<TemplateWrapper> result = new List<TemplateWrapper>();
	    // *** Note to the Salesforce security team 
	    //ContentVersion CRUD/FLS and Sharing permissions cannot be set at the profile level 
	    //(this object is not displayed on the permissions page). 
 
        List<EmailTemplate> templates = [
            SELECT Id, Name, IsActive, TemplateType
            FROM EmailTemplate
            WHERE IsActive = true AND TemplateType IN ('text', 'custom')
            ORDER BY Name
        ];
        if (!templates.isEmpty()) {
            result.add(new TemplateWrapper());
            for (EmailTemplate et : templates){
                result.add(new TemplateWrapper(et));
            }
        }

        return result;
    }

    @AuraEnabled
    public static List<scormanywhere__Course__c> getMedias() {
        if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
        	Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {

			// *** Note to the Salesforce security team
			//Courses are private, guest and community users
			//have to have access to some courses, their access to those course is controlled by the application logic. 
			//That’s why we use ‘without sharing’ here.
	        List<scormanywhere__Course__c> courses = WithoutSharingController.getAllCourses();
	        if (!courses.isEmpty()) {
	            courses.add(0, new scormanywhere__Course__c());
	            return courses;
	        }
        }
        return null;
    }

    @AuraEnabled
    public static List<Site> getSites() {
        List<TemplateWrapper> result = new List<TemplateWrapper>();
	    // *** Note to the Salesforce security team 
	    //ContentVersion CRUD/FLS and Sharing permissions cannot be set at the profile level 
	    //(this object is not displayed on the permissions page). 
	        	
        List<Site> allSites = [
            SELECT Id, Name, Subdomain, Status
            FROM Site
            WHERE Status = 'Active' AND SiteType = 'Visualforce'
            ORDER BY Name
        ];
        if (!allSites.isEmpty()) {
            allSites.add(0, new Site());
            return allSites;
        }
        return null;
    }

    @AuraEnabled
    public static EmailTemplate getTemplateBody(String selectedTemplateId){
        try {
        List<TemplateWrapper> result = new List<TemplateWrapper>();
		    // *** Note to the Salesforce security team 
		    //ContentVersion CRUD/FLS and Sharing permissions cannot be set at the profile level 
		    //(this object is not displayed on the permissions page). 
		            	
            EmailTemplate template = [
                SELECT Id, body, HtmlValue, Subject, TemplateType
                FROM EmailTemplate
                WHERE Id = :selectedTemplateId
                LIMIT 1
            ];

            if (template != null) {
                if (String.isEmpty(template.HtmlValue)) {
                    if(template.TemplateType == 'text'){
                        template.HtmlValue = template.body.replaceAll('\\n', '</br>');
                    } else {
                        template.HtmlValue = template.body;
                    }
                }

                return template;
            }
        } catch(Exception e) {
        }

        return null;
    }

    public class PreviewTemplateWrapper {
        @AuraEnabled public Boolean Success {get; set;}
        @AuraEnabled public String RenderedTemplate {get; set;}
        @AuraEnabled public String RenderedSubject {get; set;}
        @AuraEnabled public List<String> ErrorMessages {get; set;}

        public PreviewTemplateWrapper() {
            ErrorMessages = new List<String>();
        }
    }

    @AuraEnabled
    public static PreviewTemplateWrapper setEmailBody(String courseId, String mediaLink, String parentId, String subject, String templateBody, String imageHeight) {
        List<String> sourceForRender = new List<String> {subject, templateBody};
        List<Messaging.RenderEmailTemplateBodyResult> messages = Messaging.renderEmailTemplate(UserInfo.getUserId(), parentId, sourceForRender);

        String thumbnailPath;

        PreviewTemplateWrapper mainResult = new PreviewTemplateWrapper();
        mainResult.Success = false;

		// *** Note to the Salesforce security team
		//Courses are private, guest and community users
		//have to have access to some courses, their access to those course is controlled by the application logic. 
		//That’s why we use ‘without sharing’ here.

        scormanywhere__Course__c course = WithoutSharingController.getSingleCourseWithThumb(courseId);
        if(course != null){
            thumbnailPath = course.scormanywhere__Thumbnail_Path__c;
        }

        if (!messages.isEmpty() && messages.size() == 2) {
            Messaging.RenderEmailTemplateBodyResult messageSubject = messages[0];
            Messaging.RenderEmailTemplateBodyResult messageBody = messages[1];
            String previewBody = '';
            if (messageBody != null && messageSubject != null) {
                if (messageBody.getSuccess() && messageSubject.getSuccess()) {
                    if(!String.isBlank(messageBody.getMergedBody())){
                        previewBody = messageBody.getMergedBody();
                    }
                    String linkBody = '';
                    if(!String.isBlank(thumbnailPath)){
                        linkBody = '<a href="'+ mediaLink + '" target="_blank"><img src="' + thumbnailPath + '" style="height: ' + imageHeight + 'px !important;" height="' + imageHeight + '" alt="Link to media"/></a>';
                    } else {
                        linkBody = '<a href="' + mediaLink + '" target="_blank">Link to media</a>';
                    }

                    String[] parts = previewBody.split('\\{LinkShownHere\\}', 2);
                    if (!parts.isEmpty() && parts.size() == 2) {
                        previewBody = parts[0] + linkBody + parts[1];
                    }

                    mainResult.Success = true;
                    if(!String.isBlank(messageSubject.getMergedBody())){
                        mainResult.RenderedSubject = messageSubject.getMergedBody();
                    }
                    String removeString = 'input type="text" data-formula="e=mc^2';
                    Integer idx = previewBody.indexOf(removeString);
                    if(idx != -1){
                        previewBody = previewBody.substring(0, idx - 1) + previewBody.substring(idx + 87);
                    }
                    previewBody = previewBody.replaceAll('contenteditable="true"', '');
                    mainResult.RenderedTemplate = previewBody;
                } else {
                    mainResult.Success = false;

                    if (!messageSubject.getSuccess()) {
                        for (Messaging.RenderEmailTemplateError er : messageSubject.getErrors()) {
                            mainResult.ErrorMessages.add(er.getMessage());
                        }
                    }

                    if (!messageBody.getSuccess()) {
                        for (Messaging.RenderEmailTemplateError er : messageBody.getErrors()) {
                            mainResult.ErrorMessages.add(er.getMessage());
                        }
                    }
                }
            }
            return mainResult;
        }
        return mainResult;
    }

    @AuraEnabled
    public static String sendEmail(String previewBody, String parentId, List<String> toAddresses, String subject) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setCharset('UTF-8');
        message.setToAddresses(toAddresses);
        message.setHtmlBody(previewBody);
        message.setSubject(subject);
        if(Util.isValidWhatId(parentId)){
            message.setWhatId(parentId);
        }
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.Email[] {message}, true);
            system.debug('EMAIL SENDING RESULT = ' + results);

            if (!results.isEmpty()) {
                Messaging.SendEmailResult result = results[0];
                //hasError = true;
                if (result.isSuccess()) {
                    previewBody = 'Mail Sent!';
                } else {
                    previewBody = '';
                    for (Messaging.SendEmailError er : result.getErrors()) {
                        previewBody += er.getMessage();
                    }
                }
            }
        }
        catch (Exception e) {
            previewBody = e.getMessage();
        }
        return previewBody;
    }

    public static void testCall(Id mediaId, Id siteId) {
        system.debug('mediaId: '+mediaId);
        system.debug('siteId: '+siteId);

        String link = scormanywhere.ApiService.getLink('GetPublicLink', '{"courseId":"' + mediaId + '", "siteId":"' + siteId + '"}');
    }

    @AuraEnabled
    public static String getPublicLink(String mediaId, String siteId, String parentId) {
        PageReference pr = Page.getPublicLink;
        pr.getParameters().put('mediaId', mediaId);
        pr.getParameters().put('siteId', siteId);

        String link = '';
        if (!Test.isRunningTest()) {
            system.debug(pr.getContent().toString());
            link = pr.getContent().toString();
        }
        if (!String.isEmpty(parentId)) {
            link += '&tagExternalId=' + parentId;
        }

        return link;
    }
}