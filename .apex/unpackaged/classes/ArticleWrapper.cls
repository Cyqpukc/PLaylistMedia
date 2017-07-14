public with sharing class ArticleWrapper {
    @AuraEnabled public String id {get; set;}
    @AuraEnabled public String title {get; set;}
    @AuraEnabled public String lastPublishedDate {get; set;}
    @AuraEnabled public String summary {get; set;}
    @AuraEnabled public Integer viewCount {get; set;}
    @AuraEnabled public String articleType {get; set;}
    @AuraEnabled public String url {get; set;}

    @AuraEnabled public List<ArticleContentFiledWrapper> customFields { get; set; }
    @AuraEnabled public List<ArticleTopicWrapper> topics { get; set; }
    @AuraEnabled public String articleNumber { get; set; }
    @AuraEnabled public String voteType { get; set; }

    public ArticleWrapper(){}

    public ArticleWrapper(Map<String, String> customFieldsMap, Id articlId, String title, String summary, String articleNumber, String lastPublishedDate, Map<String, String> fieldLabelMap) {
        this.customFields = new List<ArticleContentFiledWrapper>();
        //get custom lookup fields
        String query = 'SELECT Id,';
        for (String fieldName : articlId.getsobjectType().getDescribe().fields.getMap().keySet()) {
            if (fieldName.endsWith('__c')) {
                String fieldType = String.valueOf(articlId.getsobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
                if (fieldType.equalsIgnoreCase(Util.REFERENCE_TYPE)) {
                    query += fieldName.replace('__c', '__r.Name') + ',';
                }
            }
        }
        query = query.removeEnd(',');
        query += ' FROM ' + articlId.getsobjectType().getDescribe().getName();
        query += ' WHERE Id = \'' + articlId + '\'';
        Sobject articleReference = Database.query(query);

        for (String fName : customFieldsMap.keySet()) {
            if (fName.endsWithIgnoreCase('__s')) {
                String fLabel = getFileFieldLabel(articlId.getsobjectType().getDescribe().fields.getMap().get(fName).getDescribe().getLabel());
                String fieldType = Util.FILE_TYPE;
                String label = fieldLabelMap.get(fName);
                this.customFields.add(new ArticleContentFiledWrapper(fLabel, customFieldsMap.get(fName), fieldType, label));
            } else {
                DescribeFieldResult fieldDescribe = articlId.getsobjectType().getDescribe().fields.getMap().get(fName).getDescribe();
                String fLabel = fieldDescribe.getLabel();
                String fieldType = String.valueOf(fieldDescribe.getType());
                //Fix for textareas
                if (fieldType.equalsIgnoreCase(Util.TEXTAREA_TYPE) && !fieldDescribe.isHtmlFormatted()) {
                    fieldType = Util.TEXTAREA_LONG_TYPE;
                }
                if (fieldType.equalsIgnoreCase(Util.REFERENCE_TYPE)) {
                    SObject lookupReference = articleReference.getSObject(fName.replace('__c', '__r'));
                    if (lookupReference != null) {
                        String label = String.valueOf(lookupReference.get('Name'));
                        this.customFields.add(new ArticleContentFiledWrapper(fLabel, customFieldsMap.get(fName), fieldType, label));
                    } else {
                        this.customFields.add(new ArticleContentFiledWrapper(fLabel, customFieldsMap.get(fName), fieldType));
                    }
                } else {
                    this.customFields.add(new ArticleContentFiledWrapper(fLabel, customFieldsMap.get(fName), fieldType));
                }
            }
        }
        this.id = articlId;
        this.title = title;
        this.summary = summary;
        this.articleNumber = articleNumber;
        this.lastPublishedDate = lastPublishedDate;
    }

    public static String getFileFieldLabel(String fieldName) {
        String fieldLabel = '';
        if (fieldName.endsWith(' (Name)')) {
            fieldLabel = fieldName.removeEnd(' (Name)');
        } else if (fieldName.endsWith(' (Body)')) {
            fieldLabel = fieldName.removeEnd(' (Body)');
        } else if (fieldName.endsWith(' (Length)')) {
            fieldLabel = fieldName.removeEnd(' (Length)');
        } else if (fieldName.endsWith(' (ContentType)')) {
            fieldLabel = fieldName.removeEnd(' (ContentType)');
        }

        return fieldLabel;
    }

    public class ArticleTopicWrapper{
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String url { get; set; }

        public ArticleTopicWrapper(String name, String url) {
            this.name = name;
            this.url = url;
        }
    }

}