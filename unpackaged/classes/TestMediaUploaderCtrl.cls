@isTest
private class TestMediaUploaderCtrl {

    @isTest
    private static void createCourse() {
        MediaUploaderCtrl controller = new MediaUploaderCtrl();

        controller.init();
        System.assertEquals('124-234-234', controller.guid);
        System.assert(controller.orgId != null);
        System.assert(controller.urlForUpload != null);
        System.assert(controller.urlForGetProgress != null);
        System.assert(controller.urlForGetStatus != null);
        System.assert(controller.networkId == null);
        System.assert(controller.prefix != null);

        System.assert(MediaUploaderCtrl.getPrefix() != null);
        System.assert(MediaUploaderCtrl.getSiteDomen() != null);
        System.assert(MediaUploaderCtrl.getSessionId() != null);
        System.assert(MediaUploaderCtrl.getCoursesFromBackend('testId') != null);
        MediaUploaderCtrl.convertToMedia('{"videoContentVersionId":"06841000001LglJAAS","duration":"11","thumbVersionId":"06841000001LglEAAS","uploadId":"06841000001LglEAAS","domain":"https://autumn16-developer-edition.na35.force.com"}');
        //System.assert(MediaUploaderCtrl.convertToMedia('{"videoContentVersionId":"06841000001LglJAAS","duration":"11","thumbVersionId":"06841000001LglEAAS","uploadId":"06841000001LglEAAS","domain":"https://autumn16-developer-edition.na35.force.com"}') != null);
    }

    @isTest
    private static void createMediaContent() {
        MediaUploaderCtrl controller = new MediaUploaderCtrl();
        Case testCase = new Case(Status = 'New', Origin = 'Phone');
        insert testCase;
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active');
        insert course;
        controller.init();
        List<scormanywhere__Related_Media__c> mediaContent = [SELECT Id, scormanywhere__Course__c FROM scormanywhere__Related_Media__c];
        System.assertEquals(0, mediaContent.size());
        MediaUploaderCtrl.createNewMediaContent(course.Id, testCase.Id);
        //System.assertEquals(course.Id, mediaContent[0].scormanywhere__Course__c);

        scormanywhere__Course__c course1 = MediaUploaderCtrl.getMedia(course.Id);
        System.assert(MediaUploaderCtrl.updateMedia(course1));
        System.assert(!MediaUploaderCtrl.uploadToSF());
    }
}