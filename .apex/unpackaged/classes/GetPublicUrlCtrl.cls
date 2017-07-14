public class GetPublicUrlCtrl {
    
    public String siteUrl {get; set;}
    
    public GetPublicUrlCtrl(){
	   List<sObject> publicSites = getSites('Active', 'Visualforce');
       
       String path = '/sites/servlet.SiteDebugMode';
       PageReference pr = new PageReference(path);
       pr.getParameters().put('guid', (String)publicSites[0].get('GuestUserId'));
       pr.getParameters().put('sitedebugmode', 'x');
       siteUrl = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
       siteUrl = siteUrl.removeEnd('/');
    }
    
    private List<sObject> getSites(String status, String siteType) {
        String query = '';
        try {
                query =
                    'SELECT GuestUserId, Id, Name, Subdomain, UrlPathPrefix, MasterLabel FROM Site ' +
                    'WHERE Status = :status ' +
                    'AND SiteType = :siteType ' +
                    'LIMIT 100';
                return Database.query(query);
        } catch (Exception e) {
            //not for all site available
            return null;
        }
    }
}