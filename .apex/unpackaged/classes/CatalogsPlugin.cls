public class CatalogsPlugin implements PluginService.CatalogsPlugin {
    public List<scormanywhere__Catalog__c> getCatalogs() {
        return [SELECT Id, Name, scormanywhere__Thumbnail_Path__c FROM scormanywhere__Catalog__c];
    }
}