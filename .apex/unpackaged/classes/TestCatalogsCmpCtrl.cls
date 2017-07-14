@isTest
public class TestCatalogsCmpCtrl {
    @isTest
    private static void getCatalogsTest() {
        Account testAcct = new Account (Name = 'My Test Account');
        insert testAcct;

        Contact testContact = new Contact (
            LastName = 'My Test Contact',
            FirstName = 'TestFirstName',
            Email = 'testemail@mail.com',
            AccountId = testAcct.Id
        );
        insert testContact;

        Id prof = [SELECT Id, usertype FROM Profile WHERE Name = 'Customer Community Login User Clone'].Id;
        
        String email = UserInfo.getUserEmail();
        
        User user = new User(
            alias = 'tts01', 
            email = email, 
            emailencodingkey = 'UTF-8', 
            lastname = 'testtest01', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testtest01@test.com',
            ProfileId = prof, 
            ContactId = testContact.Id, 
            IsActive = true
        );
        insert user;
        scormanywhere__Catalog__c catalog = new scormanywhere__Catalog__c(
            Name = 'testCatalogName'
        );
        insert catalog;

        scormanywhere__Channel__c newChannel = new scormanywhere__Channel__c(
            scormanywhere__Title__c = 'channelName'
        );
		insert newChannel;
        System.runAs(user){
            test.startTest();
            List<ChannelWrapper> cannels = CatalogsCmpCtrl.getChannels();
            System.assertEquals(0, cannels.size());
        	List<CatalogWrapper> result = CatalogsCmpCtrl.getCatalogs();

        	System.assertEquals('testCatalogName', result[0].name);
        	test.stopTest();
        }
        List<ChannelWrapper> cannels = CatalogsCmpCtrl.getChannels();
        System.assertEquals(1, cannels.size());
    }
    
	private static String getRandomString(Integer countOfChars) {
		String result = String.valueOf(Math.round((Math.random() * (1 - 99999999)) + 1)).mid(1, countOfChars);
		return result;
	}    
    
}