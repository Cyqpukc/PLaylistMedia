@isTest
private class TestArticleContentCmpCtrl {

    @isTest
    private static void getArticle() {
        String articleId = createArticle();
        if(!String.isBlank(articleId)){
            Sobject sarticle = ArticleContentCmpCtrl.getArticleObject(articleId);
            System.assert(sarticle != null);
            ArticleWrapper details = ArticleContentCmpCtrl.getArticleDetails(articleId, '');
            System.debug(details);
            System.assertEquals(details.title, 'title1');
        }
        System.assert(ArticleContentCmpCtrl.getPrefix() != null);
        System.assert(ArticleContentCmpCtrl.getSiteDomain() != null);
        System.assert(ArticleContentCmpCtrl.isGuestUser() != null);
        System.assert(ArticleContentCmpCtrl.createTopicLink(articleId, 'topicName') != null);
        ArticleContentFiledWrapper newArticl = new ArticleContentFiledWrapper('', '', '', '');
        ArticleContentFiledWrapper newArticl1 = new ArticleContentFiledWrapper('', '', '');
        ArticleWrapper.ArticleTopicWrapper newArticlTopic = new ArticleWrapper.ArticleTopicWrapper('', '');
        ArticleWrapper newArticlWrapper = new ArticleWrapper();
        System.assert(ArticleWrapper.getFileFieldLabel('(Name)') != null);
        System.assert(ArticleWrapper.getFileFieldLabel('(Body)') != null);
        System.assert(ArticleWrapper.getFileFieldLabel('(Length)') != null);
        System.assert(ArticleWrapper.getFileFieldLabel('(ContentType)') != null);
    }

    @isTest
    private static void unVote() {
        String articleId = createArticle();
        if(!String.isBlank(articleId)){
            ArticleContentCmpCtrl.voteArticleUpByCurrentUserById(articleId, true);
            ArticleContentCmpCtrl.unVoteArticleByCurrentUserById(articleId);
            List<Vote> voteRecords = [SELECT Id FROM vote where ParentId = :articleId];
            System.assertEquals(voteRecords.size(), 0);
        }
    }

    @isTest
    private static void applyFix() {
        String content = '<iframe width="545" height="438" frameborder="0" src="/apex/abc"></iframe>';
        content = ArticleContentCmpCtrl.applyIframeFix(content, 'www.sfgate.com/article');
        System.assertNotEquals(content.indexOf('sf'), -1);
    }

    private static String createArticle(){
        Map<String, Schema.sObjectType> GlobalSchema = Schema.getGlobalDescribe();
        String articleType = '';
        sObject article;
        for(String key: GlobalSchema.keySet()) {
            if(key.indexOf('__kav') != -1) {
                System.debug(key);
				articleType = key;
                break;
            }
        }
        if(!String.isBlank(articleType)){
            article = Schema.getGlobalDescribe().get(articleType).newSObject();
            article.put('UrlName', 'name1');
            article.put('Title', 'title1');
            article.put('Summary', 'summary1');
            insert article;
            return article.Id;
        }
        return null;
    }
}