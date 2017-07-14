trigger UploadFilesTrigger on ContentVersion (after insert) {
    List<scormanywhere__Course__c> newMedias = new List<scormanywhere__Course__c>();
    List<ContentDocumentLink> listCdls = new List<ContentDocumentLink>();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            for (ContentVersion cv : Trigger.new) {
            if (cv.Description != null && cv.Description.contains('custom') == true) {
                String typeOfFile = '';
                if (cv.FileType == 'TEXT') {
                  typeOfFile = 'TXT';   
                } else {
                  typeOfFile = cv.FileType;  
                }
              newMedias.add( new scormanywhere__Course__c(
                    Name = cv.Title.toLowerCase() + '.' + typeOfFile.toLowerCase(),
          scormanywhere__SCORM_Training_Path__c = 'sfdclocal://' + cv.Id,
                    scormanywhere__SCORM_Training_Type__c = cv.FileType,
                    scormanywhere__SCORM_Title__c = cv.Title,
                    scormanywhere__SCORM_File_Size__c = cv.ContentSize,
                  scormanywhere__Status__c = 'Active')
                );
                ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = UserInfo.getOrganizationId();
        cdl.ShareType = 'V';
                listCdls.add(cdl);
                }
            }
            insert listCdls;
            insert newMedias;
        }
    }

}