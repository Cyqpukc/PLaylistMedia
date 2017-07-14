trigger Course on scormanywhere__Course__c (after insert) {
    /*if(Trigger.isInsert && Trigger.new.size() == 1){
		multM__c newMMedia = new multM__c();
        insert newMMedia;
        scormanywhere__Related_Media__c newRMedia = new scormanywhere__Related_Media__c();
        newRMedia.scormanywhere__Course__c = Trigger.new[0].Id;
        newRMedia.scormanywhere__Object_API_Name__c	 = 'multM__c';
        newRMedia.scormanywhere__Object_Id__c = newMMedia.Id;
        insert newRMedia;
    }  */  
}