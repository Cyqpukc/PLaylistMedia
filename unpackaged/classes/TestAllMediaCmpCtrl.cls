@isTest
private class TestAllMediaCmpCtrl {

    @isTest
    private static void getVideos(){
        List<scormanywhere__Course__c> courses = new List<scormanywhere__Course__c>();
        courses.add(new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active'));
        courses.add(new scormanywhere__Course__c(Name='SearchTest',scormanywhere__SCORM_Training_Type__c='youtube', scormanywhere__Status__c = 'Active'));
        courses.add(new scormanywhere__Course__c(Name='Test3',scormanywhere__SCORM_Training_Type__c='mkv', scormanywhere__Status__c = 'Active'));
        insert courses;
		scormanywhere__Channel__c newChannel = new scormanywhere__Channel__c();
        newChannel.scormanywhere__Title__c = 'testchannel';
        insert newChannel;
        scormanywhere__Channel_Course__c newchannelCourse = new scormanywhere__Channel_Course__c();
        newchannelCourse.scormanywhere__Channel__c = newChannel.Id;
        newchannelCourse.scormanywhere__Course__c = courses[0].Id;
        insert newchannelCourse;
        System.assert(AllMediaCmpCtrl.getAllVideos('', newChannel.Id, null).size()>0);
        System.assert(AllMediaCmpCtrl.getAllVideos('', 'All', null).size()>1);
        System.assert(AllMediaCmpCtrl.getAllVideos('SearchTest', 'All', null).size()==1);
        System.assert(AllMediaCmpCtrl.getRecomendedVideos('', 1).size()>0);
        System.assert(AllMediaCmpCtrl.getMediaLink(courses[0].Id, Site.getBaseCustomUrl()) != null);
        System.assert(AllMediaCmpCtrl.getShareAccess('link') != null);
		System.assert(AllMediaCmpCtrl.getUserType() != null);
        System.assert(AllMediaCmpCtrl.getMedia(new List<String>{courses[0].Id, courses[1].Id}) != null);
        System.assert(AllMediaCmpCtrl.getPublicLinkNewWindow(courses[0].Id, 'testId') != null);
        System.assert(AllMediaCmpCtrl.getPublicLinkAp(courses[0].Id, 'testId','domain', 'autoplay=0') != null);
        System.assert(AllMediaCmpCtrl.shareCourseInCommunity(courses[0].Id, 'testemail', 'domain', 'autoplay=0'));
        System.assert(AllMediaCmpCtrl.getLink(courses[0].Id) != null);

        System.assert(AllMediaCmpCtrl.getVideoDetail(courses[0].Id) != null);

		scormanywhere__Catalog__c catalogs = new scormanywhere__Catalog__c();
        catalogs.Name = 'testCatalog';
        insert catalogs;
        scormanywhere__Course_Catalog__c course_catalog = new scormanywhere__Course_Catalog__c();
        course_catalog.scormanywhere__Course__c = courses[0].Id;
        course_catalog.scormanywhere__Catalog__c = catalogs.Id;
        insert course_catalog;
        CarouselWrapper carouselW = new CarouselWrapper();
        CarouselPageWrapper carousel = new CarouselPageWrapper();
        System.assert(carousel.cssClass == 'item');
        scormanywhere__Transcript__c transcript = new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[0].Id);
        insert transcript;
		System.assert(AllMediaCmpCtrl.deleteRelatedMedia(courses[0].Id) != null);
    }

    @isTest
    private static void testChannel(){
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active');
        insert course;

        System.assert(AllMediaCmpCtrl.getPinAccess());

        System.assert(AllMediaCmpCtrl.getChannels(null).size() == 0);
        List<ChannelWrapper> channels = AllMediaCmpCtrl.addChannel('New channel', '');
        System.assert(AllMediaCmpCtrl.getChannels(null).size() == 1);

        AllMediaCmpCtrl.addMediaToChannel(channels[0].Id, course.Id, '');
        AllMediaCmpCtrl.addMediaToChannel('', course.Id, 'New channel 2');

        List<scormanywhere__Channel_Course__c> channelCourses = [SELECT Id FROM scormanywhere__Channel_Course__c];
        System.assertEquals(2, channelCourses.size());

		List<ChannelWrapper> channelWrapper = AllMediaCmpCtrl.changeNameChannel(channels[0].Id, 'update Name');

        List<scormanywhere__Channel__c> updChannels = [SELECT Id, scormanywhere__Title__c FROM scormanywhere__Channel__c WHERE scormanywhere__Title__c = 'update Name'];
        System.assertEquals(1, updChannels.size());

        System.assert(AllMediaCmpCtrl.removeMediaFromChannel(channels[0].Id, course.Id).size() == 0);

	    AllMediaCmpCtrl.removeChannel(channels[0].Id);
        System.assert(AllMediaCmpCtrl.getChannels(null).size() == 1);

        List<ChannelWrapper> newChannels = AllMediaCmpCtrl.addChannel('New channel', course.Id);
        System.assert(AllMediaCmpCtrl.getChannels(null).size() == 2);
        System.assert(AllMediaCmpCtrl.shareContent(course.Id, 'testemail@domen.com'));
    }
}