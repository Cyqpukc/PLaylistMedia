@isTest
private class SearchCustomControllerTest {

    @IsTest
    private static void testGetVideos () {

        SearchCustomController controller = new SearchCustomController();
        List<MediaWrapper> topicVideos = SearchCustomController.getVideos('test', false, null);
        System.assertEquals(0, topicVideos.size());

        Account tAccount = new Account(Name = 'TestAcc');
        insert tAccount;

        // Insert Contact
        Contact testContact = new Contact();
        testContact.LastName = 'Test Contact Last Name';
        testContact.AccountId = tAccount.Id;
        insert testContact;

		// Insert User
        Profile sysAdminProfile = [
            SELECT id
            FROM Profile
            WHERE name='Customer Community User'
        ];
        User externalUser = new User();
        externalUser.FirstName = 'joe';
        externalUser.Username = 'joe178937selhorn17839@gmail.com';
        externalUser.LastName = 'selhornTest';
        externalUser.Email = 'joe.selhorn@gmail.com';
        externalUser.Alias = 'JSlTest';
        externalUser.CommunityNickname = 'JSTest';
        externalUser.TimeZoneSidKey = '';
        externalUser.LocaleSidKey = '';
        externalUser.EmailEncodingKey = '';
        externalUser.ProfileId = sysAdminProfile.Id;
        externalUser.LanguageLocaleKey = 'en_US';
        externalUser.TimeZoneSidKey = 'America/Los_Angeles';
        externalUser.LocaleSidKey = 'en_US';
        externalUser.EmailEncodingKey = 'ISO-8859-1';
        externalUser.ContactId = testContact.id;
        insert externalUser;
        System.debug('externalUser - ' + externalUser);
        System.runAs(externalUser) {
            List<MediaWrapper> nonTopicVideos = SearchCustomController.getVideos('test', false, null);
            System.assertEquals(0, nonTopicVideos.size());
        }
    }

    @IsTest(SeeAllData=true)
    private static void testGetArticles () {

        SearchCustomController controller = new SearchCustomController();
        List<ArticleWrapper> articles = SearchCustomController.getArticles('test', false, null);

        System.assertEquals(0, articles.size());

        ArticleWrapper buffA = new ArticleWrapper();
        buffA.title = 'Test Title';
        buffA.lastPublishedDate = 'Test date';
        buffA.id = 'Test id';
        buffA.summary = 'Test Summary';
        buffA.viewCount = 3;
        buffA.articleType = 'testType';
        buffA.url = 'testUrl';
        System.debug('buffA - ' + buffA);
        System.assertNotEquals(null, buffA);
    }


}