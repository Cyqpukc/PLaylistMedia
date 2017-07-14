public with sharing class getPublicLinkCtrl {
    public static String result
    {
        get { 
            String mId = ApexPages.currentPage().getParameters().get('mediaId');
            String sId = ApexPages.currentPage().getParameters().get('siteId');
            return scormanywhere.ApiService.getLink('GetPublicLink', '{"courseId":"'+mId+'", "siteId":"'+sId+'"}');
        }
    }
}