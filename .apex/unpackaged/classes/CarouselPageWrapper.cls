public with sharing class CarouselPageWrapper {

    @AuraEnabled public String cssClass {get; set;}
    @AuraEnabled public List<MediaWrapper> videoList {get; set;}
    public final Integer VIDSPERPAGE = 6;

    public CarouselPageWrapper() {
        cssClass = 'item';
        videoList = new List<MediaWrapper>();
    }
}