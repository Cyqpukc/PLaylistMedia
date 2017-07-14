public with sharing class MediaUpdaterCtrl {
    Transient public Blob contentFile { get; set; }
    public String nameFile { get; set; }
    public Boolean isDone { get; set; }
    private Map<String, String> titlesByOriginalName = new Map<String, String>();
    private Map<String, String> descriptionsByOriginalName = new Map<String, String>();
    
    public MediaUpdaterCtrl() {
        isDone = false;
    }
    
    public PageReference upload() {
        PageReference result;
        if (contentFile == null || contentFile.size() <= 0) {
            return null;
        }
        List<String> fileLines;
        try {
             fileLines = contentFile.toString().split('\n');
        } catch (System.StringException e) {
            return null;
        }
        if (fileLines.size() <= 1) {
            fileLines = contentFile.toString().split('\r');
        }
        List<String> customMessages = new List<String>();
		List<String> cleanFields = new List<String>();
        try {
            Integer i = 1;
            while (i < fileLines.size()) {
                List<String> row = fileLines[i].split(',');
        		String compositeField;
        		Boolean makeCompositeField=false;
                for(String field : row) {
            		if(field.startsWith('"') && field.endsWith('"')) {
                		cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
            		} else if(field.startsWith('"')) {
                		makeCompositeField = true;
                		compositeField = field;
            		} else if(field.endsWith('"')) {
                		compositeField += ',' + field;
                		cleanFields.add(compositeField.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                		makeCompositeField = false;
            		} else if(makeCompositeField) {
                		compositeField +=  ',' + field;
            		} else{
                		cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
            		}
        		}
                //if (row.size() == 3) {
                   titlesByOriginalName.put(cleanFields[0].trim(),cleanFields[2].trim());
                   //descriptionsByOriginalName.put(row[0].trim(),row[2].trim()); 
                //} else {
                    //TODO: Error. Row Length
                //}
                i++;
            }
            System.debug(titlesByOriginalName);
            System.debug(cleanFields);
            WithoutSharingOps wsops = new WithoutSharingOps();
            List<scormanywhere__Course__c> medias = wsops.getMediasByOriginalName(titlesByOriginalName.keySet());
            System.debug(medias);
            for (scormanywhere__Course__c item : medias) {
                String typeOfFile = '';
                if (item.scormanywhere__SCORM_Training_Type__c == 'TEXT') {
                  typeOfFile = 'TXT';   
                } else {
                  typeOfFile = item.scormanywhere__SCORM_Training_Type__c;  
                }
                String itemOriginalName = item.scormanywhere__SCORM_Title__c + '.' + typeOfFile.toLowerCase();
                itemOriginalName = itemOriginalName.toLowerCase();
              	//item.scormanywhere__Description__c = descriptionsByOriginalName.get(itemOriginalName);
                item.Name = titlesByOriginalName.get(itemOriginalName);
            }
            wsops.updateMedias(medias);
            isDone = true;
            result = null;
        } catch (System.NullPointerException ex) {
            isDone = false;
        }
        return result;
    }
    
    @TestVisible
    private without sharing class WithoutSharingOps {
       public void updateMedias(List<scormanywhere__Course__c> medias){
          update medias;
       }
        
        public List<scormanywhere__Course__c> getMediasByOriginalName(Set<String> originalNames){
            System.debug(originalNames);
            List<scormanywhere__Course__c> medias = new List<scormanywhere__Course__c>();
            medias = [
              SELECT Id, Name, scormanywhere__Description__c, scormanywhere__SCORM_Title__c, scormanywhere__SCORM_Training_Type__c
                FROM scormanywhere__Course__c
                WHERE Name IN :originalNames
            ];  
            return medias;
        }
    }


}