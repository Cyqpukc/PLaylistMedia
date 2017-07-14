@IsTest(SeeAllData=true)
private class CommunityChatterUploaderCtrlTest {

    @isTest
    static void testUploader() {

        test.setCurrentPage(Page.CommunityChatterUploader);
        ApexPages.currentPage().getParameters().put('uploadId', 'testetset');

        CommunityChatterUploaderCtrl chup = new CommunityChatterUploaderCtrl();
        String uploadId = chup.uploadId;
        String uploaderUrl = chup.getUploadCourseUrl();
        chup.redirectWithParams();
        System.assertNotEquals(CommunityChatterUploaderCtrl.courseId, null);
        List<FeedItem> beforePost = new List<FeedItem>();
        beforePost = [
        	SELECT Id
            FROM FeedItem
        ];
        CommunityChatterUploaderCtrl.postToFeed(CommunityChatterUploaderCtrl.courseId, 'TestMessage', null);
        List<FeedItem> afterPost = new List<FeedItem>();
        afterPost = [
        	SELECT Id
            FROM FeedItem
        ];
        System.assert(afterPost.size()>beforePost.size());
    }

}