/* *******************************************************************************************************************
* Class Name   : AEXP_GCP_NavigationCtrl
* Description  : Controller class for AEXP_GCP_GoToCommunity_Salesforce1 and AEXP_GCP_GoToSalesforce_MastHead.
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2016
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                  Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/

public class AEXP_GCP_NavigationCtrl {
    /**
     * @description <Method to grab sites base URL>                                                        
     * @return <returns URL>
     **/
    @AuraEnabled
    public static String siteBaseUrl() {
        return Site.getBaseUrl(); //eg: https://teamprfcnt-americanexpressgcppartners.cs3.force.com/community
    }
    
    /**
     * @description <Method to grab sites base request URL>                                                        
     * @return <returns request URL>
     **/
    @AuraEnabled
    public static String siteBaseRequestUrl() {
        return Site.getBaseRequestUrl();  //eg: https://teamprfcnt-americanexpressgcppartners.cs3.force.com
    }
    
    /**
     * @description <Method to retrieve UI theme>                                                        
     * @return <returns UI theme>
     **/
    @AuraEnabled
    public static String getUiTheme() {
        return UserInfo.getUiTheme();
    }
    
    /**
     * @description <Method to verify 'go to salesforce' display is showing>                                                        
     * @return <returns true>
     **/
    @AuraEnabled
    public static Boolean isDisplayGoToSalesforce() {
        return true;
    }
    
    /**
     * @description <Method to retrieve community network id>                                                        
     * @return <returns network id if found, else null>
     **/
    @AuraEnabled
    public static String getCommunityNetWorkId() {
        Common_Settings__c cSetting = Common_Settings__c.getValues('AEXP_GCP_COMMUNITY_NAME');
        String communityName = cSetting.Value__c;
        Network[] networks = [SELECT Id FROM Network WHERE Name = :communityName];
        system.debug(networks);
        if(networks.size()>0) {
            return String.valueOf(networks[0].id).substring(0,15);
        } else {
            return null;
        }
    }
    
    /**
     * @description <Method to pull salesforce base url>                                                        
     * @return <returns URL>
     **/
    public static String salesforceBaseUrl() {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm().toLowerCase();
        return baseUrl;
    }
    
      /**
     * @description <Method for redirect name>                                                         
     * @return <returns redirect name of new community site>
     **/
    public static String getRedirectNewCommunityFlag(){        
        Common_Settings__c cSetting = Common_Settings__c.getValues('AEXP_GCP_REDIRECT_NEW_COMMUNITY_SITE');        
        if (cSetting != null){
            return cSetting.Value__c;
        }
        else{
            return '';
        }
    }
}