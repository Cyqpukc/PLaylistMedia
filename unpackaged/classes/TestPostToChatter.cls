@isTest(SeeAllData=true)
public class TestPostToChatter {

    static testmethod void testNewPostToChatter() {
        CollaborationGroup cg = new CollaborationGroup(Name='Test',CollaborationType='Public');
        List<CollaborationGroup> cgs = new List<CollaborationGroup>();
        cgs.add(cg);
        insert cgs;
        String json='[{"List":[{"str1":1,"str2":2,"str3":[{"tes1t":1,"test2":1,"test3":3},{"test1":2,"test2":4,"test3":5}]}]}]';
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test',scormanywhere__Thumbnail_Path__c='Test/Path',scormanywhere__SCORM_Manifest_Data__c=json);
        insert course;
        System.assert(PostToChatterCtrl.getMyGroupsList().size() > 0);
        Test.startTest();
        PostToChatterCtrl.postHere('["'+cg.Id+'"]', course.Id, 'TestMessage');
        Test.stopTest();
    }

}