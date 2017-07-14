@isTest
private class TestSimpleMediaCmpCtrl {
	
    @IsTest
    private static void testGetVideos () {
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active');
        insert course;
        System.assert(SimpleMediaCmpCtrl.getEmbeddedLink(course.Id,Site.getBaseCustomUrl()) != null);
        System.assert(SimpleMediaCmpCtrl.getPrefix() != null);
        System.assert(SimpleMediaCmpCtrl.getCourse(course.Id) != null);
        System.assert(SimpleMediaCmpCtrl.shareContent(course.Id, 'testemail') != null);
        System.assert(SimpleMediaCmpCtrl.getPublicLinkNewWindow(course.Id,  'siteId') != null);
        System.assert(SimpleMediaCmpCtrl.getPublicLinkAp(course.Id, 'siteId', 'domain', 'autoplay=0') != null);
    }
}