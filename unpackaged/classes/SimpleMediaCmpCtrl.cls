public with sharing class SimpleMediaCmpCtrl {

    @AuraEnabled
    public static String getEmbeddedLink(String courseId, String currentUrl) {
        return Util.createEmbeddedLink(courseId, currentUrl);
    }

    @AuraEnabled
    public static String getPrefix() {
        System.debug('Site.getPathPrefix() - ' + Site.getPathPrefix());
        return (Site.getPathPrefix() != '/s') ? Site.getPathPrefix().removeEnd('/s') : '';
    }

    @AuraEnabled
    public static scormanywhere__Course__c getCourse(String courseId) {
        return WithoutSharingController.getCourse(courseId);
    }

    @AuraEnabled
    public static Boolean shareContent(String contentId, String emailTo) {
        return Util.sendMediaLink(contentId, emailTo);
    }

    @AuraEnabled
    public static String getPublicLinkNewWindow(String myCourseId, String siteId) {
        return Util.getPublicLinkNewWindow(myCourseId, siteId);
    }

    @AuraEnabled
    public static String getPublicLinkAp(String myCourseId, String siteId, String domain, String autoplay) {
        return Util.getPublicLinkAp(myCourseId, siteId, domain, autoplay);
    }
}