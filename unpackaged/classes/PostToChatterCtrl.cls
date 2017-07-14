public with sharing class PostToChatterCtrl {
    @AuraEnabled
    public static list<ChatterGroupWrapper> getMyGroupsList(){
        list<ChatterGroupWrapper> lstGroups = new list<ChatterGroupWrapper>();
        lstGroups.add(new ChatterGroupWrapper(false, 'me', 'My Feed', ''));
        List<CollaborationGroup> collaborGroup = new List<CollaborationGroup>();
        Id currentUserId = UserInfo.getUserId();

        // *** Note to the Salesforce security team
        //We do not want regular users to have direct access to the CollaborationGroup object via CRUD/FLS settings, so we use "without sharing"
        //to allow a regular user to indirectly access certain fields from the CollaborationGroup object during a publish new feed
        //This includes regular users, community user.
        system.debug(Util.isObjectFieldAccessibility('CollaborationGroup', 'NetworkId'));

        // *** Note to the Salesforce security team
        //We do not want regular users to have direct access to the CollaborationGroupMember object via CRUD/FLS settings, so we use "without sharing"
        //to allow a regular user to indirectly access certain fields from the CollaborationGroup object during a publish new feed
        //This includes regular users, community user.
        system.debug(Util.isObjectFieldAccessibility('CollaborationGroupMember', 'CollaborationGroupId'));

        List<CollaborationGroupMember> memberships = [
            SELECT Id, CollaborationGroupId
            FROM CollaborationGroupMember
            WHERE MemberId = :currentUserId
        ];
        Set<Id> participatedGroupIds = new Set<Id>();
        for (CollaborationGroupMember cgm : memberships) {
            participatedGroupIds.add(cgm.CollaborationGroupId);
        }

        try {
            // *** Note to the Salesforce security team
            //CollaborationGroup CRUD/FLS and Sharing permissions cannot be set at the profile level
            //(this object is not displayed on the permissions page).
            //We use ‘without sharing’ and use application logic to limit access to this object.
            String nId = Network.getNetworkId();
            String query = '';
            if (nId != null) {
                query = 'SELECT Id, CollaborationType, Name, Description,  isBroadcast, (Select MemberId, CollaborationRole From GroupMembers Where MemberId=:userId) FROM CollaborationGroup WHERE NetworkId = \''+nId+'\' AND IsArchived = false';
            } else {
                query = 'SELECT Id, CollaborationType, Name, Description,  isBroadcast, (Select MemberId, CollaborationRole From GroupMembers Where MemberId=:userId) FROM CollaborationGroup WHERE NetworkId != null AND IsArchived = false ';
            }
            query += ' ORDER BY Name';
            query += ' LIMIT 1000';
            collaborGroup = WithoutSharingController.getDynamicQuery(query, currentUserId);
        } catch (exception e) {
            collaborGroup = [SELECT Id, CollaborationType, Name, Description,  isBroadcast, (Select MemberId, CollaborationRole From GroupMembers Where MemberId=:currentUserId) From CollaborationGroup ORDER BY Name LIMIT 1000];
        }

        String collaborationRole =  'Admin';
        for (CollaborationGroup varColGroup : collaborGroup) {

            if (varColGroup.CollaborationType == 'Private' && varColGroup.GroupMembers.size() > 0) {
                if(varColGroup.isBroadcast){
                    if(varColGroup.GroupMembers[0].CollaborationRole == collaborationRole){
                        lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                    }
                } else{
                    lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                }
            } else if (varColGroup.CollaborationType == 'Public') {
                if(varColGroup.isBroadcast){
                    if(varColGroup.GroupMembers.size() > 0 && varColGroup.GroupMembers[0].CollaborationRole == collaborationRole){
                        lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                    }
                } else{
                    lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                }
            } else if (varColGroup.CollaborationType == 'Unlisted' && varColGroup.GroupMembers.size() > 0) {
                if(varColGroup.isBroadcast){
                    if(varColGroup.GroupMembers[0].CollaborationRole == collaborationRole){
                        lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                    }
                } else{
                    lstGroups.add(new ChatterGroupWrapper(false, varColGroup.Id, varColGroup.Name, varColGroup.Description));
                }
            }
        }

        return lstGroups;
    }

    @AuraEnabled
    public static String postHere(String groupIds, String courseId, String message){
        // *** Note to the Salesforce security team
        //Courses are private, guest and community users
        //have to have access to some courses, their access to those course is controlled by the application logic.
        //That’s why we use ‘without sharing’ here.
        scormanywhere__Course__c course = new scormanywhere__Course__c();
        if(Util.isObject('scormanywhere__Course__c', Util.IS_ACCESSIBLE)) {
            course = WithoutSharingController.getSingleCourse(courseId);
        }
        message = message == null ? '' : message;
        String addVideoParams = '';
        try {
            String jstr = course.scormanywhere__SCORM_Manifest_Data__c;
            Map<String, Object> m =
             (Map<String, Object>)
               JSON.deserializeUntyped(jstr);
            addVideoParams = '&videoType='+String.valueOf(m.get('videoType'))+'&videoData='+EncodingUtil.urlEncode(String.valueOf(m.get('videoData')), 'UTF-8');
        } catch (exception e) {

        }
        List<String> groupsIds = (List<String>)System.JSON.deserialize(groupIds, List<String>.class);

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (String idGroup : groupsIds) {
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.feedElementType  = ConnectApi.FeedElementType.FeedItem;
            input.subjectId = idGroup;

            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = message;

            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            messageBodyInput.messageSegments.add(textSegmentInput);
            input.body = messageBodyInput;

            ConnectApi.LinkCapabilityInput inputLinkCapability = new ConnectApi.LinkCapabilityInput();
            Url domain = new Url(System.Url.getSalesforceBaseUrl().toExternalForm());
            String commonLink = domain.getHost()+ (Site.getPathPrefix() != '/s'?Site.getPathPrefix().removeEnd('/s'):'');
            String domainForChatterLink = Util.getDomainForChatterLink();
            String chatterLink;
            if(String.isNotBlank(domainForChatterLink)){
                chatterLink = domainForChatterLink;
            } else {
                chatterLink = 'https://services.appinium.com';
            }
            chatterLink += '/chatterplayer?courseid='+course.Id+'&showSFPlayer=1&title='+EncodingUtil.urlEncode(course.Name,'UTF-8')+'&sfdomain='+EncodingUtil.urlEncode(commonLink,'UTF-8')+'&courseType=';
            if(!String.isBlank(course.scormanywhere__SCORM_Training_Type__c)){
                chatterLink += EncodingUtil.urlEncode(course.scormanywhere__SCORM_Training_Type__c,'UTF-8');
            }
            chatterLink += addVideoParams;
            inputLinkCapability.url = chatterLink;
            if (course.scormanywhere__Thumbnail_Path__c != null) {
                String fileName = course.scormanywhere__Thumbnail_Path__c;
                if(fileName != null) {
                    if (fileName.startsWith('/sfc') == true) {
                        String thumbUrl = EncodingUtil.urlEncode(fileName,'UTF-8');
                        inputLinkCapability.url += '&thumb='+thumbUrl.substringBefore('%26uploadId%3D') + '&uploadId='  + thumbUrl.substringAfter('%26uploadId%3D') + '&sfThumb=' + EncodingUtil.urlEncode(WithoutSharingController.getSfThumbLinkForChatter(fileName.substringAfter('download/').substringBefore('?')), 'UTF-8');
                        System.debug('inputLinkCapability.url - ' + inputLinkCapability.url);
                    } else {
                        List<String> parts = filename.split('/');
                        fileName = parts.get(parts.size()-1);
                        inputLinkCapability.url += '&thumb='+EncodingUtil.urlEncode(fileName,'UTF-8');
                    }
                }
            }
            ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementCapabilitiesInput.link = inputLinkCapability;

            input.capabilities = feedElementCapabilitiesInput;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }

        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        return '';
    }
}