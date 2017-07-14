({
	doInit : function(component, event, helper) {
        component.set("v.parentId", 'a0D41000006dody');     
        var str = window.location.href;
        var arr = str.split('?');
        alert(str);
        var params = new Array();
        for(var i=0; i < arr.length; i++){
            var temp = arr[i].split('=');
            console.log(temp);
            if(temp[0].length > 0){
                params[temp[0]] = temp[1];
            }
        }
        //alert(params);
        if('recordId' in params){
            //console.log('detail');
          //  console.log(params['recordId']);
        //    component.set("v.parentId", params['recordId']);
        }
	}
})