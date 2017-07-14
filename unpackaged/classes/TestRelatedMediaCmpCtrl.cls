@isTest
private class TestRelatedMediaCmpCtrl {

    @isTest static void testGetMedia() {
        Case newCase = new Case();
        insert newCase;
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test3',scormanywhere__SCORM_Training_Type__c='mkv');
        insert course;
        scormanywhere__Related_Media__c newMedia = new scormanywhere__Related_Media__c(scormanywhere__Course__c = course.Id, scormanywhere__Object_Id__c = newCase.Id);
        insert newMedia;

        System.assertEquals(1, RelatedMediaCmpCtrl.getContent(newCase.Id).size());
        System.assert(RelatedMediaCmpCtrl.getLink(course.Id) != null);
    }
}