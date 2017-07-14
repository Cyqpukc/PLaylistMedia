public with sharing class CatalogsCmpCtrl {

    @AuraEnabled
    public static List<CatalogWrapper> getCatalogs() {
		// *** Note to the Salesforce security team 
		//We do not check CRUD/FLS permissions for the User object here because the SOQL below should be able to "select" fields from that record in the user's context even if CRUD/FLS permissions are not set for that user. 
		//This includes community users, guest users    	
        List<User> currentUserList = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        List<scormanywhere__Catalog__c> catalogs;

        //Checking plugin
        String pluginClass = 'CatalogsPlugin';
        String pluginNamespace = '';
        List<ApexClass> pluginClasses = getApexClassesForPlugin(pluginClass);
        if(pluginClasses != null && pluginClasses.size() == 1){
            if(pluginClasses[0].NamespacePrefix != null){
                pluginNamespace = pluginClasses[0].NamespacePrefix;
            }
            //Initialize instance if valid match is found
        	Type t = Type.forName(pluginNamespace, pluginClass);
            if (t != null) {
                PluginService.CatalogsPlugin plugin = (PluginService.CatalogsPlugin)t.newInstance();
                catalogs = plugin.getCatalogs();
            }
        } else {
            if(pluginClasses != null && pluginClasses.size() > 1) {
                System.debug('Multiple plugin configurations found for : ' + pluginClass);
            }
			// *** Note to the Salesforce security team
			//Catalogs are private, guest and community users
			//have to have access to some Catalogs, their access to those Catalog is controlled by the application logic. 
			//That’s why we use ‘without sharing’ here.
            if(Util.isObject('scormanywhere__Catalog__c', Util.IS_ACCESSIBLE) &&
        		Util.isField('scormanywhere__Catalog__c', 'Name', Util.IS_ACCESSIBLE)) {        
				catalogs = WithoutSharingController.getDynamicQuery('SELECT Id, Name, scormanywhere__Thumbnail_Path__c FROM scormanywhere__Catalog__c LIMIT 1000');
        	}
        }

        if (catalogs != null && !catalogs.isEmpty()) {
        	List<CatalogWrapper> catalogsWrapped = new List<CatalogWrapper>();
            for(scormanywhere__Catalog__c catalog : catalogs) {
            	catalogsWrapped.add(new CatalogWrapper(catalog));
            }
            system.debug('catalogsWrapped = ' + catalogsWrapped);
            return catalogsWrapped;
        }
        return null;
    }

    @AuraEnabled
    public static List<ChannelWrapper> getChannels(){
    	
        List<ChannelWrapper> result = new List<ChannelWrapper>();
        if(Util.isObject('scormanywhere__Channel__c', Util.IS_ACCESSIBLE) &&
        	Util.isField('scormanywhere__Channel__c', 'scormanywhere__Title__c', Util.IS_UPDATEABLE)) {        
	        for(scormanywhere__Channel__c channels : [SELECT Id, scormanywhere__Title__c
	                                   FROM scormanywhere__Channel__c
	                                   WHERE CreatedById = : UserInfo.getUserId()
	                                   ORDER BY scormanywhere__Title__c])
	        {
	            result.add(new ChannelWrapper(channels));
	        }
        }
        return result;
    }

    private static List<ApexClass> getApexClassesForPlugin(String pluginClass) {
        return WithoutSharingController.getApexClassesForPlugin(pluginClass);
    }

    @AuraEnabled
    public static String getLink(String courseId) {
        return Util.getLink(courseId);
    }
}