@isTest
public with sharing class TestArticleDetailCmpCtrl {
    @isTest
    private static void getArticle() {
        sObject article;
        /*
        Map<String, Schema.sObjectType> GlobalSchema = Schema.getGlobalDescribe();
        for(String key: GlobalSchema.keySet()) {
            if(key.indexOf('articl') != -1 || key.indexOf('kav') != -1) {
              System.debug(key);
            for(String k: Schema.getGlobalDescribe().get(key).getDescribe().fields.getMap().keySet())
              //if(k.endsWith('__c') || k.endsWithIgnoreCase('body__s'))
                System.debug('-----  ' + k);
            }
        }*/
        try {
            article = Schema.getGlobalDescribe().get('Knowledge__kav').newSObject();
            article.put('UrlName', 'name1');
            article.put('Title', 'title1');
            article.put('Summary', 'summary1');
            //article.put('lastpublisheddate', Date.today());
            insert article;
        } catch (Exception e){
            System.debug(e.getMessage());
        }

        Sobject sarticle = ArticleDetailCmpCtrl.getArticleObject(article.Id);
        System.assert(sarticle != null);

        ArticleWrapper details = ArticleDetailCmpCtrl.getArticleDetails(article.Id, '');
        System.debug(details);
        System.assertEquals(details.title, 'title1');
    }

    @isTest
    private static void unVote() {
        sObject article = Schema.getGlobalDescribe().get('Knowledge__kav').newSObject();
        article.put('UrlName', 'Name');
        article.put('Title', 'Title');
        article.put('Summary', 'Summary');
        insert article;
        System.debug(article);
        ArticleDetailCmpCtrl.voteArticleUpByCurrentUserById(article.Id, true);

        ArticleDetailCmpCtrl.unVoteArticleByCurrentUserById(article.Id);
        List<Vote> voteRecords = [SELECT Id FROM vote where ParentId = :article.Id];
        System.assertEquals(voteRecords.size(), 0);
    }

    @isTest
    private static void applyFix() {
        String content = '<iframe width="545" height="438" frameborder="0" src="/apex/abc"></iframe>';
        content = ArticleDetailCmpCtrl.applyIframeFix(content, 'www.sfgate.com/article');
        System.assertNotEquals(content.indexOf('sf'), -1);
    }
}