public with sharing class SearchCustomController {

    private static Map<String, String> describeMap {
        get {
            if (describeMap == null) {
                describeMap = new Map<String,String>();
                Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                Set<String> keySet = globalDescribe.keySet();
                for (String key : keySet) {
                    Schema.SObjectType objectType = globalDescribe.get(key);
                    if (key.endsWith('ka') || key.endsWith('kb')) {
                        describeMap.put(objectType.getDescribe().getKeyPrefix().toLowerCase(), objectType.getDescribe().getLabel());
                    }
                }
            }
            return describeMap;
        }
    }

    private static User currentUser {
        get {
			// *** Note to the Salesforce security team
			//We do not check CRUD/FLS permissions for the User object here because the SOQL below should be able to "select" fields from that record in the user's context even if CRUD/FLS permissions are not set for that user.
			//This includes community user
            if (currentUser == null) {
                User result = [
                    SELECT Id, ContactId, Contact.AccountId, ProfileId
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                ];
            System.debug('result - ' + result);
            return result;
            }
            return currentUser;
        }
    }

    @AuraEnabled
    public static List<MediaWrapper> getVideos(String searchString, Boolean isTopicSearch, String topicId) {
        List<MediaWrapper> result = new List<MediaWrapper>();
        List<scormanywhere__Course__c> courses = getCourses(searchString, isTopicSearch, topicId);
        for (scormanywhere__Course__c course : courses) {
            result.add(new MediaWrapper(course));
        }
        return result;
    }

    @AuraEnabled
    public static List<scormanywhere__Course__c> getCourses(String searchString, Boolean isTopicSearch, String topicId) {
        List<scormanywhere__Course__c> result = new List<scormanywhere__Course__c>();
        if (!isTopicSearch) {
            String searchQuery = 'FIND \'*' + String.escapeSingleQuotes(searchString) + '*\' IN ALL FIELDS ' +
                                 'RETURNING scormanywhere__Course__c(Id, Name, scormanywhere__Thumbnail_Path__c,scormanywhere__SCORM_Training_Type__c, CreatedDate, OwnerId, Owner.Name, scormanywhere__Enable_all_external_users__c, scormanywhere__Enable_all_internal_users__c';
            searchQuery += getWhereStatement() + ')';

            System.debug(searchQuery);
			if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
        		Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
				// *** Note to the Salesforce security team
				//Courses are private, guest and community users
				//have to have access to some courses, their access to those course is controlled by the application logic.
				//That’s why we use ‘without sharing’ here.
            	List<List<sObject>> searchList = WithoutSharingController.getDynamicSearchQuery(searchQuery);
            	result = (List<scormanywhere__Course__c>)searchList[0];
        	}
        } else {
            String soqlQuery = 'SELECT Id, Name, scormanywhere__SCORM_Keywords__c, scormanywhere__Thumbnail_Path__c,scormanywhere__SCORM_Training_Type__c, CreatedDate, OwnerId, Owner.Name, scormanywhere__Enable_all_external_users__c, scormanywhere__Enable_all_internal_users__c';
            soqlQuery += ' FROM scormanywhere__Course__c' + getWhereStatement() + ' LIMIT 1000';

			if(Util.isObject(Util.OBJECT_APINAME_COURSE, Util.IS_ACCESSIBLE) &&
        		Util.isField(Util.OBJECT_APINAME_COURSE, 'Name,scormanywhere__Description__c',Util.IS_ACCESSIBLE)) {
				// *** Note to the Salesforce security team
				//Courses are private, guest and community users
				//have to have access to some courses, their access to those course is controlled by the application logic.
				//That’s why we use ‘without sharing’ here.

            	List<scormanywhere__Course__c> courses = WithoutSharingController.getDynamicQuery(soqlQuery);
            	String topicName = getTopicNameFromId(topicId);
	            for (scormanywhere__Course__c c : courses) {
	                if (!String.isBlank(c.scormanywhere__SCORM_Keywords__c) && c.scormanywhere__SCORM_Keywords__c.containsIgnoreCase(topicName)) {
	                    result.add(c);
	                }
	            }
        	}
        }
        return result;
    }

    @AuraEnabled
    public static String getWhereStatement() {
        String whereStatement = '';
        Boolean isUserGuest = String.isBlank(UserInfo.getSessionId());
        if(isUserGuest){
            whereStatement += ' WHERE scormanywhere__Status__c = \'Active\' AND scormanywhere__Public__c = true ';
        } else{
            whereStatement += ' WHERE scormanywhere__Status__c = \'Active\' AND (id = \'\' OR ';
            System.debug('currentUser - ' + currentUser);
            Object disabledCBISharingObj = Util.getDynamicCustomSetting('scormanywhere__ViewTrac_Settings__c', 'Disable_CreatedById_Sharing__c');
            Boolean disabledCBISharing = (disabledCBISharingObj != null && ((Boolean)disabledCBISharingObj) == true);
            List<String> condList = new List<String>();
            Set<Id> courseIds = new Set<Id>();
            if (isExternalUser(currentUser)) {
                condList.add(' scormanywhere__Enable_all_external_users__c = true ');

                if (Util.isObjectFieldAccessibility('Course_Account__c', 'Course__c, Account__c')) {
                    Id accountId = currentUser.Contact.AccountId;
                    // *** Note to the Salesforce security team
                    //Courses are private, guest and community users
                    //have to have access to some courses, their access to those course is controlled by the application logic.
                    //That’s why we use ‘without sharing’ here.
                    List<sObject> courseAccounts = WithoutSharingController.getDynamicQuery('SELECT Id, Course__c FROM Course_Account__c WHERE Account__c = \'' + accountId + '\'');
                    for (sObject ca: courseAccounts) {
                        courseIds.add(String.valueOf(ca.get('Course__c')));
                    }
                }
            } else {
                condList.add(' scormanywhere__Enable_all_internal_users__c = true ');
            }

            if (!disabledCBISharing) {
                condList.add(' OwnerId = \'' + currentUser.Id + '\'');
            }

            if(Util.isObjectFieldAccessibility('Course_Profile__c', 'Course__c, Profile_Id__c')){

                String profileId = '%' + String.valueOf(currentUser.ProfileId).substring(0,15) + '%';
                String queryCourseProfile = 'SELECT Id, Course__c FROM Course_Profile__c WHERE Profile_Id__c LIKE \'' + profileId + '\'';
                System.debug('queryCourseProfile - ' + queryCourseProfile);
                for(SObject item : WithoutSharingController.getDynamicQuery(queryCourseProfile)){
                    courseIds.add((Id)item.get('Course__c')); // if course assigned to profile
                }
            }
            if (!courseIds.isEmpty()) {
                String curCond = ' Id IN (';
                for (Id key : courseIds) {
                    curCond += '\'' + key + '\',';
                }
                curCond = curCond.removeEnd(',') + ')';
                condList.add(curCond);
            }
            for (String curCond : condList) {
                whereStatement += curCond + ' OR ';
            }
            whereStatement = whereStatement.removeEnd('OR ') ;
            whereStatement += ')';
            System.debug(whereStatement);
        }
        return whereStatement;
    }

    private static Boolean isExternalUser(User user) {
        return user.ContactId != null;
    }

    @AuraEnabled
    public static List<ArticleWrapper> getArticles(String searchString, Boolean isTopicSearch, String topicId) {
        List<ArticleWrapper> wrappedArticles = new List<ArticleWrapper>();
        try {
            searchString = String.escapeSingleQuotes(searchString.trim());

            String topicSearchString = '';
            Set<Id> eIds = new Set<Id>();
            Set<Id> kavIds;
            if (isTopicSearch) {
                List<TopicAssignment> taList = [SELECT Id, EntityId FROM TopicAssignment WHERE TopicId = : topicId LIMIT 1000];
                kavIds = new Set<Id>();
                for (TopicAssignment ta : taList) {
                    kavIds.add(ta.EntityId);
                }
                topicSearchString += ' AND Id IN :kavIds ';
            }

            List<sObject> articles;
            if (searchString.length() < 2) {
			    // *** Note to the Salesforce security team
			    //KnowledgeArticleVersion CRUD/FLS and Sharing permissions cannot be set at the profile level
			    //(this object is not displayed on the permissions page).
                List<sObject> searchList = Database.query(
                    'SELECT Id, Title, LastPublishedDate, Summary, KnowledgeArticleId, ArticleType, UrlName, PublishStatus ' +
                    'FROM KnowledgeArticleVersion ' +
                    'WHERE Language = \'en_US\' and PublishStatus = \'Online\' ' + topicSearchString +
                    'LIMIT 1000 '
                );


                if (searchList != null) {
                    articles = searchList;
                } else {
                    articles = new List<sObject>();
                }
            } else {
                searchString = '\'*' + searchString + '*\'';

			    // *** Note to the Salesforce security team
			    //KnowledgeArticleVersion CRUD/FLS and Sharing permissions cannot be set at the profile level
			    //(this object is not displayed on the permissions page).
                List<List<sObject>> searchList = search.query(
                    'FIND ' + searchString + ' IN ALL FIELDS ' +
                    'RETURNING KnowledgeArticleVersion(' +
                        'Id, Title, LastPublishedDate, Summary, KnowledgeArticleId, ArticleType, UrlName, PublishStatus ' +
                        'WHERE Language = \'en_US\' and PublishStatus = \'Online\' ' + topicSearchString +
                    ') ' +
                    'LIMIT 1000 '
                );
                articles = searchList[0];
            }

		    // *** Note to the Salesforce security team
		    //KnowledgeArticleViewStat CRUD/FLS and Sharing permissions cannot be set at the profile level
		    //(this object is not displayed on the permissions page).
            List<sObject> viewStats = Database.query(
                'SELECT Id, NormalizedScore, Parent.Id, ViewCount ' +
                'FROM KnowledgeArticleViewStat ' +
                'WHERE Channel = \'Csp\' ' +
                'ORDER BY NormalizedScore ' +
                'LIMIT 10000 '
            );

            if (!Util.isObjectFieldAccessibility('Network', null)) {
                return wrappedArticles;
            }

            ConnectApi.Community  currentCommunity = ConnectApi.Communities.getCommunity(Network.getNetworkId());

            for (sObject article: articles) {
                ArticleWrapper wrappedArticle = new ArticleWrapper();
                wrappedArticle.id = (Id)article.get('id');
                wrappedArticle.title = (String)article.get('title');
                wrappedArticle.lastPublishedDate = ((DateTime)article.get('LastPublishedDate')).format('MMM d, Y');
                wrappedArticle.summary = (String)article.get('Summary');
                wrappedArticle.viewCount = 0;
                for (sObject viewStat: viewStats) {
                    if (viewStat.get('ParentId') == article.get('KnowledgeArticleId')) {
                        wrappedArticle.viewCount = (Integer)viewStat.get('ViewCount');
                    }
                }
                wrappedArticle.articleType = getArticleType((String)article.get('Id'));
                wrappedArticle.url = currentCommunity.siteUrl + '/s/article/' + article.get('KnowledgeArticleId') + '/' + article.get('UrlName');

                wrappedArticles.add(wrappedArticle);
            }
        } catch(Exception e) {
            System.debug(e.getMessage() + ' ' + String.valueOf(e.getLineNumber()));
        }

        return wrappedArticles;
    }

    private static String getArticleType(String articleId) {
        String articlePrefix = articleId.substring(0,3).toLowerCase();
        Set<String> keySet = describeMap.keySet();
        String articleType = describeMap.containsKey(articlePrefix) ? describeMap.get(articlePrefix) : null;
        return articleType;
    }

    private static String getTopicNameFromId(String topicId) {
        String result;
	    // *** Note to the Salesforce security team
	    //Topic CRUD/FLS and Sharing permissions cannot be set at the profile level
	    //(this object is not displayed on the permissions page).

        List<sObject> topic = Database.query('SELECT Name FROM Topic WHERE Id = :topicId LIMIT 1');
        if (topic != null && !topic.isEmpty()) {
            result = (String)topic[0].get('Name');
        }
        return result;
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
}