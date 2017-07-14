public with sharing class CarouselWrapper {

    @AuraEnabled public List<CarouselPageWrapper> pages {get; set;}
    public CarouselWrapper() {
        pages = new List<CarouselPageWrapper>();
    }
}