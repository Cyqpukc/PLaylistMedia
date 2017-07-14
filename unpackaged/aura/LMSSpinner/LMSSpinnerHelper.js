({
    showHideSpinner : function(component, isVisible) {
        var spinner = component.find("lmsSpinner");
        if(spinner.getElement()){
            if(isVisible) {
                spinner.getElement().style.display = 'block';
            }else{
                spinner.getElement().style.display = 'none';
            }
        }
    }
})