@isTest(SeeAllData=true)
public class TestPostToMyFeedCtrl {
    
    static testmethod void testPostToMyFeed() {
        scormanywhere__Course__c course = new scormanywhere__Course__c(Name='Test',scormanywhere__Thumbnail_Path__c='Test' );
        insert course;      
        List<FeedItem> itemsBefore = new List<FeedItem>();
        List<FeedItem> itemsAfter = new List<FeedItem>();
        itemsBefore = [
            SELECT Id
            FROM FeedItem
        ];
        System.assert(String.isBlank(PostToMyFeedCtrl.postToMyFeedCtrl(course.id, 'TestMessage')));
        itemsAfter = [
            SELECT Id
            FROM FeedItem
        ];
        System.assert(itemsBefore.size()<itemsAfter.size());
    }

}