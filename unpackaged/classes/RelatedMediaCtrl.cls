public without sharing class RelatedMediaCtrl {
    public multM__c mm {get;set;}
    
    public RelatedMediaCtrl(ApexPages.StandardController stdController) {
        this.mm = (multM__c)stdController.getRecord();
    }
}