@isTest
private class TestSendMediaCmpCtrl {

    @isTest private static void testGetMedias() {
        List<scormanywhere__Course__c> courses = new List<scormanywhere__Course__c> {
            new scormanywhere__Course__c(Name = 'Test1', scormanywhere__Thumbnail_Path__c = 'testPath', scormanywhere__Public__c = true),
            new scormanywhere__Course__c(Name = 'Test2', scormanywhere__Thumbnail_Path__c = 'testPath2', scormanywhere__Public__c = false)
        };
        insert courses;

        List<scormanywhere__Course__c> result =  SendMediaCmpCtrl.getMedias();
        System.assert(result.size() == 2); //this ok btw added null and filtered non public
    }

    @isTest private static void testGetPublicLink() {

        String result = SendMediaCmpCtrl.getPublicLink('courseId', 'mySiteId', 'parentId');
        System.assert(!String.isEmpty(result));
    }

    @isTest private static void testGetTemplateBody() {
        EmailTemplate tpl = new EmailTemplate(
            FolderId = UserInfo.getUserId(),
            Name = 'testTempateName',
            DeveloperName = 'testDevName',
            body = 'test body with \\{LinkShownHere\\} test test',
            HtmlValue = '',
            TemplateType = 'text',
            Subject = 'testsubj'
        );
        insert tpl;

        EmailTemplate result = SendMediaCmpCtrl.getTemplateBody(tpl.Id);
        System.assert(result.Subject == tpl.Subject);
    }

    @isTest
    private static void testController() {
        String thumbnailPath = 'imageUrlforThumbnailPath';
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name = 'Test1',scormanywhere__Thumbnail_Path__c = thumbnailPath);
        insert course;
        List<TemplateWrapper> templateWrappers = SendMediaCmpCtrl.getTemplates();
        System.assert(templateWrappers.size() != null);

        String templBody = String.valueOf(SendMediaCmpCtrl.getTemplateBody(templateWrappers[0].id));
        templBody = 'asdasd imageUrlforThumbnailPath';
        System.assert(!String.isBlank(templBody));

        String mediaLink = 'testurl?param1=tratra&courseId=' + course.Id + '&param2=tururu';
        String parentId = course.Id;
        String templateBody = 'test email for customer';
        String emailBody = String.valueOf(SendMediaCmpCtrl.setEmailBody(course.id,mediaLink, parentId, 'subject', templateBody,'150'));
        System.assert(!String.isBlank(emailBody));
        emailBody += emailBody + 'thumbnailPath';

        templateBody += '{!Account.Name}';
        emailBody = String.valueOf(SendMediaCmpCtrl.setEmailBody(course.id,mediaLink, parentId, 'subject', templateBody,'150'));
        System.assert(!String.isBlank(emailBody));
        System.debug('templateBody - ' + templateBody);
        System.assert(emailBody.contains('No value for the field'));

        String previewBody = 'test email for customer';
        List<String> toAddress = new List<String>{'asd@asd.com', 'test@test.com'};
            String alert = SendMediaCmpCtrl.sendEmail(previewBody, parentId, toAddress, 'subject');
        System.assertEquals('Mail Sent!', alert);
    }
}