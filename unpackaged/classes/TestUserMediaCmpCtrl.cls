@isTest
public class TestUserMediaCmpCtrl {

    static testmethod void testMyMedia(){
        List<scormanywhere__Transcript__c> transcripts = new List<scormanywhere__Transcript__c>();
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test3',scormanywhere__SCORM_Training_Type__c='mkv', scormanywhere__Status__c = 'Active');
        insert course;
        scormanywhere__Transcript__c course1 = new scormanywhere__Transcript__c(scormanywhere__Course__c=course.Id,scormanywhere__User__c=UserInfo.getUserId(), scormanywhere__Test_Launch__c = false);
        scormanywhere__Transcript__c course2 = new scormanywhere__Transcript__c(scormanywhere__Course__c=course.Id,scormanywhere__User__c=UserInfo.getUserId(), scormanywhere__Test_Launch__c = false);
        transcripts.add(course1);
        transcripts.add(course2);
        insert transcripts;
        System.assert(UserMediaCmpCtrl.getViewedMedia(UserInfo.getUserId()).size()>1);
        System.assert(UserMediaCmpCtrl.getUploadedMedia('').size()>0);
        System.assert(UserMediaCmpCtrl.getPrefix() != null);
        System.assert(UserMediaCmpCtrl.getUserId() != null);
        
        List<String> coursesId = new List<String>();
        coursesId.add(course.Id);
        List<String> transcriptsId = new List<String>();
        transcriptsId.add(transcripts[0].Id);
        transcriptsId.add(transcripts[1].Id);
        
        System.assert(UserMediaCmpCtrl.getCourses(UserInfo.getUserId(), coursesId) != null);
        System.assert(UserMediaCmpCtrl.getTranscripts(transcriptsId) != null);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String email = UserInfo.getUserEmail();
        User user = new User(Alias = 'standt', Email=email,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='s1w@testorg.com');
        insert user;
        String currentUser = UserInfo.getUserId();
        System.runAs(user){
            System.assertEquals(1, UserMediaCmpCtrl.getUploadedMedia(currentUser).size());
        }
        System.assert(!String.isBlank(Util.debugInfo('testmsg', 'testmsg', 'testmsg')));
        Util.sendEmail('error', 'subject');
    }
}