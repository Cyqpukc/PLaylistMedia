global with sharing class PluginService {
	global class PluginServiceException extends Exception{}
    
    global interface CatalogsPlugin{
        List<scormanywhere__Catalog__c> getCatalogs();
    }
}