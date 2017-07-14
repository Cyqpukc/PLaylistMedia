public with sharing class CatalogWrapper {
        @AuraEnabled public String catalogId {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String link {get; set;}
        @AuraEnabled public String backImage {get; set;}

        public CatalogWrapper(scormanywhere__Catalog__c catalog) {
            //link = '/s/catalog#' + catalog.Id;
            catalogId = catalog.Id;
            link = '';
            String temp = Network.getLoginUrl(Network.getNetworkId());
            if (temp != null) {
                link += temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/');
            }
            link += '/';
            //link += 'catalog-content#' + catalog.Id + ':';
            // TODO: default image "no image";
            backImage = catalog.scormanywhere__Thumbnail_Path__c;
            name = catalog.Name.replace('_', ' ');
        }
}