public with sharing class ChannelWrapper {

    @AuraEnabled public Id id {get; set;}
    @AuraEnabled public String name {get; set;}
    @AuraEnabled public Boolean containsVideo {get; set;}
    @AuraEnabled public Integer countVideo {get; set;}
    @AuraEnabled public String link {get; set;}

    public ChannelWrapper(ChannelWrapper cw) {
        id = cw.Id;
        name = cw.name;
        containsVideo = cw.containsVideo;
        countVideo = cw.countVideo;
    }

    public ChannelWrapper(scormanywhere__Channel__c channel) {
        id = channel.Id;
        name = channel.scormanywhere__Title__c;
        countVideo = channel.scormanywhere__Channels__r.size();
        link = '';
        if (!Test.isRunningTest()) {
        	String temp = Network.getLoginUrl(Network.getNetworkId());
            if (temp != null) {
            	link += temp.removeEnd(temp.substringAfterLast('/')).removeEnd('/');
            }
        }
        link += '/catalog-content#:' + channel.Id;
    }
}