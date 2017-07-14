({
    goToCommunity: function(component){
         var action = component.get("c.getCommunityNetWorkId");
        action.setCallback(this, function(a){
            var state = a.getState();
            // alert(state);
            if (state === "SUCCESS") {
                var rtnValue = a.getReturnValue();
               // alert(rtnValue);
                if (rtnValue !== null) { 
              		//TODO, if lightning experience open, add tab in lightning experience, need to open in a new _blank
                    //This sitePrefix value is gotten from AEXP_GCP_CommunitySiteBaseComponent
                    var sitePrefix = component.get("v.sitePrefix");
                    //alert(sitePrefix +'/servlet/networks/switch?networkId='+rtnValue);
                    window.open(sitePrefix +'/servlet/networks/switch?networkId='+rtnValue,'_self');
                }
            } 
        });
        $A.enqueueAction(action); 
    }

})