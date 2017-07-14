public with sharing class ArticleDetailCmpCtrl {

	@AuraEnabled
	public static String getArticleQuery(Id articleId) {
		//get all fields of selected article including custom
		//id,knowledgearticleid,ownerid,isdeleted,publishstatus,versionnumber,islatestversion,isvisibleinapp,isvisibleinpkb,isvisibleincsp,isvisibleinprm,createddate,
		//createdbyid,lastmodifieddate,lastmodifiedbyid,systemmodstamp,language,title,urlname,archiveddate,archivedbyid,summary,articlenumber,firstpublisheddate,
		//lastpublisheddate,articlecreateddate,sourceid,articletype,description__c,notes__c,additional_information__c
		String result = 'SELECT ';
		for (String fieldName : articleId.getsobjectType().getDescribe().fields.getMap().keySet()) {
			result += fieldName + ',';
		}
		result = result.removeEnd(',');
		result += ' FROM ' + articleId.getsobjectType().getDescribe().getName();
		result += ' WHERE Id = \'' + articleId + '\'';
		return result;
	}

	@AuraEnabled
	public static Sobject getArticleObject(Id articleIdString) {
		Id articleId = Id.valueOf(articleIdString);
		Sobject article = Database.query(getArticleQuery(articleId));

		return article;
	}


	@AuraEnabled
	public static ArticleWrapper getArticleDetails(String articleIdString, String currentUrl) {
		Id articleId = Id.valueOf(articleIdString);
		Sobject article = Database.query(getArticleQuery(articleId));
		Map<String, String> customFields = new Map<String, String>();
		Map<String, String> fieldLabelMap = new Map<String, String>();
		for (String fieldName : articleId.getsobjectType().getDescribe().fields.getMap().keySet()) {
			if (fieldName.endsWith('__c')) {
				String fieldLabel = articleId.getsobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getName();
				String fieldType = String.valueOf(articleId.getsobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
				String fieldValue;
				String fixedValue;
				if (fieldType.equalsIgnoreCase(Util.REFERENCE_TYPE) && article.get(fieldName) != null) {
					if (article.get(fieldName) != null) {
						fieldValue = getSiteDomain() + getPrefix() + '/s/detail/' + String.valueOf(article.get(fieldName));
					}
				} else if (fieldType.equalsIgnoreCase(Util.DATE_TYPE) && article.get(fieldName) != null) {
					Date formatedDate = (Date) article.get(fieldName);
					fieldValue = formatedDate.format();
				} else if (fieldType.equalsIgnoreCase(Util.DATETIME_TYPE) && article.get(fieldName) != null) {
					DateTime formatedDateTime = (Datetime) article.get(fieldName);
					fieldValue = formatedDateTime.format('M/dd/yyyy h:mm a');
				} else {
					fieldValue = String.valueOf(article.get(fieldName));
				}

				if (!String.isBlank(fieldValue)) {
					fixedValue = applyIframeFix(fieldValue, currentUrl);
				}
				customFields.put(fieldLabel, fixedValue != null ? fixedValue : fieldValue);
			}
			if (fieldName.endsWithIgnoreCase('body__s')) {
				String lengthFieldName = fieldName.replace('body__s', 'length__s');
				String titleFieldName = fieldName.replace('body__s', 'name__s');
				Integer fileLength = Integer.valueOf(article.get(lengthFieldName));
				String fileName = String.valueOf(article.get(titleFieldName));
				if (fileLength != null && fileLength > 0) {
					fieldLabelMap.put(fieldName, fileName);
					customFields.put(fieldName, String.format(Util.FILE_TEMPLATE, new List<String> {getSiteDomain() + getPrefix() + '/', articleId, fieldName}));
				} else {
					fieldLabelMap.put(fieldName, null);
					customFields.put(fieldName, null);
				}
			}
		}
		String title = (String) article.get('title');
		String summary = (String) article.get('summary');
		String articleNumber = (String) article.get('articleNumber');
		DateTime lpd = (Datetime) article.get('lastpublisheddate');
		String lastPublishedDate = lpd != null ? lpd.format('MMMM dd, yyyy'): '';
		ArticleWrapper result = new ArticleWrapper(customFields, articleId, title, summary, articleNumber, lastPublishedDate, fieldLabelMap);
		String knowledgeArticleId = getKnowledgeArticleId(articleId);
		result.voteType = getArticlesCurrentUserVoteTypeById(knowledgeArticleId);
		result.articleType = articleId.getsobjectType().getDescribe().getLabel();
		return result;
	}

	@AuraEnabled
	public static String applyIframeFix(String content, String currentUrl) {
		if (!content.containsIgnoreCase('<iframe') && !content.containsIgnoreCase('SCORM_Player')) return null;
		if (content.indexOf('src="') != content.lastIndexOf('src="')) {
			System.debug('content has many iframes');
		}
		List<String> srcList = new List<String>();
		String temp = content;
		while (temp.containsIgnoreCase('src="')) {
			String src = temp.substring(temp.indexOf('src="') + 5, temp.indexOf('"', temp.indexOf('src="') + 6));
			System.debug(src);
			if (src.containsIgnoreCase('/apex/')) {
				srcList.add(src);
			}
			temp = temp.substring(temp.indexOf('src="') + 5);
		}
		Map<String, String> replacementMap = new Map<String, String>();
		System.debug('currentUrl');
		System.debug(currentUrl);
		for (String src : srcList) {
			String relativeSrc = src.substring(src.indexOf('/apex/'));
			if (currentUrl.indexOf('/s/') > -1) {
				relativeSrc = currentUrl.substring(0, currentUrl.indexOf('/s/')) + relativeSrc;
			} else if (currentUrl.indexOf('/article') > -1) {
				relativeSrc = currentUrl.substring(0, currentUrl.indexOf('/article')) + relativeSrc;
			}
			replacementMap.put(src, relativeSrc);
		}
		System.debug('replacements:');
		System.debug(replacementMap);
		String result = content;
		for (String src : replacementMap.keySet()) {
			result = result.replace(src, replacementMap.get(src));
		}
		System.debug('result');
		System.debug(result);
		return result;
	}

	@AuraEnabled
	public static void voteArticleUpByCurrentUserById(Id articleId, Boolean isUp) {
		String knowledgeArticleId = getKnowledgeArticleId(articleId);
		try {
			unVoteArticleByCurrentUserById(knowledgeArticleId);
			Vote voteRecord = new Vote();
			voteRecord.ParentId = knowledgeArticleId;
			voteRecord.Type = isUp ? Util.ARTICLE_THUMB_UP_TYPE : Util.ARTICLE_THUMB_DOWN_TYPE;

			insert voteRecord;
		} catch (DmlException ex) {
			System.debug(ex.getMessage());
			try {
				Vote voteRecord = new Vote();
				voteRecord.ParentId = knowledgeArticleId;
				voteRecord.Type = isUp ? '5' : '1';

				insert voteRecord;
			} catch (DmlException exx) {
				System.debug(exx.getMessage());
			}
		}
	}

	public static void unVoteArticleByCurrentUserById(Id articleId) {
		try {
			List<Vote> voteRecords = [SELECT Id FROM vote where CreatedById = :UserInfo.getUserId() AND ParentId = :articleId];
			if (voteRecords.size() > 0) {
				delete voteRecords;
			}
		} catch (DmlException ex) {
			System.debug(ex.getMessage());
		}
	}

	public static String getArticlesCurrentUserVoteTypeById(Id articleId) {
		List<Vote> voteResults = [SELECT parentId, Type, CreatedById FROM Vote WHERE ParentId = :articleId AND CreatedById = :Userinfo.getUserId()];

		if (voteResults.size() > 0) {
			String vote = voteResults[0].Type;
			if(vote == Util.ARTICLE_THUMB_UP_TYPE || vote == '5'){
				return Util.ARTICLE_THUMB_UP_TYPE;
			}
			if(vote == Util.ARTICLE_THUMB_DOWN_TYPE || vote == '1'){
				return Util.ARTICLE_THUMB_DOWN_TYPE;
			}
		}
		return '';
	}

	public static String getKnowledgeArticleId(Id articleId) {
		SObject article = getArticleObject(articleId);

		return (String) article.get('knowledgearticleid');
	}

	public static String getPrefix() {
		System.debug('Site.getPathPrefix() - ' + Site.getPathPrefix());
		return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
	}

	public static String getSiteDomain() {
		System.debug('URL.getSalesforceBaseUrl().getHost() - ' + URL.getSalesforceBaseUrl().toExternalForm());
		return URL.getSalesforceBaseUrl().toExternalForm();
	}
}