({
    handleClick : function(cmp, event) {
        console.log("in handleClick");
        // call the method declared by <aura:method> in the markup 
        cmp.sampleMethod("2");
    },

    doAction : function(cmp, event) {
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.param1;
            console.log("param1: " + param1);
            // add your code here
        }
    },
})