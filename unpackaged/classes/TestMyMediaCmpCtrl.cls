@isTest
private with sharing class TestMyMediaCmpCtrl {

    @isTest
    private static void getVideos(){
        List<scormanywhere__Course__c> courses = new List<scormanywhere__Course__c>();
        courses.add(new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active', scormanywhere__Description__c = 'description coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription coursedescription course'));
        courses.add(new scormanywhere__Course__c(Name='SearchTest',scormanywhere__SCORM_Training_Type__c='youtube', scormanywhere__Status__c = 'Active'));
        courses.add(new scormanywhere__Course__c(Name='Test3',scormanywhere__SCORM_Training_Type__c='mkv', scormanywhere__Status__c = 'Active'));
        courses.add(new scormanywhere__Course__c(Name='Test4',scormanywhere__SCORM_Training_Type__c='youtube', scormanywhere__Status__c = 'Active'));
        courses.add(new scormanywhere__Course__c(Name='Test5',scormanywhere__SCORM_Training_Type__c='youtube', scormanywhere__Status__c = 'Active',scormanywhere__Thumbnail_Path__c = 'https://testurl'));
        insert courses;

        scormanywhere__Channel__c newChannel = new scormanywhere__Channel__c();
        newChannel.scormanywhere__Title__c = 'testchannel';
        insert newChannel;

        scormanywhere__Channel_Course__c newchannelCourse = new scormanywhere__Channel_Course__c();
        newchannelCourse.scormanywhere__Channel__c = newChannel.Id;
        newchannelCourse.scormanywhere__Course__c = courses[0].Id;
        insert newchannelCourse;

        List<scormanywhere__Transcript__c> transcripts = new List<scormanywhere__Transcript__c>();
        transcripts.add(new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[0].Id, scormanywhere__User__c = UserInfo.getUserId()));
        transcripts.add(new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[1].Id, scormanywhere__User__c = UserInfo.getUserId()));
        transcripts.add(new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[2].Id, scormanywhere__User__c = UserInfo.getUserId()));
        transcripts.add(new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[3].Id, scormanywhere__User__c = UserInfo.getUserId(),scormanywhere__SCORM_Progress_Measure__c = '0.1'));
        transcripts.add(new scormanywhere__Transcript__c(scormanywhere__Course__c = courses[4].Id, scormanywhere__User__c = UserInfo.getUserId(), scormanywhere__SCORM_Progress_Measure__c = '0.7'));
        insert transcripts;
        MyMediaCmpCtrl.updateTranscript(transcripts[0].Id);

        System.assert(MyMediaCmpCtrl.getAllUserVideos('', newChannel.Id).size()>0);
        System.assert(MyMediaCmpCtrl.getAllUserVideos('', 'All').size()>1);
        System.assert(MyMediaCmpCtrl.getAllUserVideos('SearchTest', 'All').size()==1);
        System.assert(MyMediaCmpCtrl.getVideoDetail(courses[0].Id) != null);
        System.assert(MyMediaCmpCtrl.getCarouselData('', 'All') != null);

    }

    @isTest
    private static void testChannel(){
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test1',scormanywhere__SCORM_Training_Type__c='mp4', scormanywhere__Status__c = 'Active');
        insert course;

        System.assert(MyMediaCmpCtrl.getPinAccess());

        System.assert(MyMediaCmpCtrl.getChannels().size() == 0);
        List<ChannelWrapper> channels = MyMediaCmpCtrl.addChannel('New channel', '');
        System.assert(MyMediaCmpCtrl.getChannels().size() == 1);

        MyMediaCmpCtrl.addMediaToChannel(channels[0].Id, course.Id, '');
        MyMediaCmpCtrl.addMediaToChannel('', course.Id, 'New channel 2');

        List<scormanywhere__Channel_Course__c> channelCourses = [SELECT Id FROM scormanywhere__Channel_Course__c];
        System.assertEquals(2, channelCourses.size());

        List<ChannelWrapper> channelWrapper = MyMediaCmpCtrl.changeNameChannel(channels[0].Id, 'update Name');

        List<scormanywhere__Channel__c> updChannels = [SELECT Id, scormanywhere__Title__c FROM scormanywhere__Channel__c WHERE scormanywhere__Title__c = 'update Name'];
        System.assertEquals(1, updChannels.size());

        MyMediaCmpCtrl.removeMediaFromChannel(channels[0].Id, course.Id);

        MyMediaCmpCtrl.removeChannel(channels[0].Id);
        System.assert(MyMediaCmpCtrl.getChannels().size() == 1);

        List<ChannelWrapper> newChannels = MyMediaCmpCtrl.addChannel('New channel', course.Id);
        System.assert(MyMediaCmpCtrl.getChannels().size() == 2);
    }

}