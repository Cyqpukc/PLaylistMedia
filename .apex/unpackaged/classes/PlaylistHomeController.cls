public class PlaylistHomeController {

	@AuraEnabled
	public static List<CatalogWrapper> getCatalogs() {
		List<scormanywhere__Catalog__c> catalogs;

		String pluginClass = 'CatalogPlugin';
		String pluginNameSpace = '';
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

		System.debug('Catalogs ' + catalogs.size());

		for (Integer i = 0; i < catalogs.size(); i++) {
			System.debug('Name ' + catalogs.get(i).Name);
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

	private static List<ApexClass> getApexClassesForPlugin(String pluginClass) {
		return WithoutSharingController.getApexClassesForPlugin(pluginClass);
	}
}