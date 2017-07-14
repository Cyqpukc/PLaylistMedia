({
    resetChannelList : function(component, helper) {
        var elements = component.find('channelListItem');
        if (elements.length){} else {
            elements = [elements]
        }
        for(var i=0; i<elements.length; i++) {
            $A.util.removeClass(elements[i], 'disabled');
        }
    },
    showHandler : function(component, helper, channelId, action) {
        var infoBlock = helper.getElementByAttribute(component.find("infoBlock"), "id", "iNf"+channelId);
        var removeBlock = helper.getElementByAttribute(component.find("removeBlock"), "id", "rM"+channelId);
        var editBlock = helper.getElementByAttribute(component.find("editBlock"), "id", "eD"+channelId);
        var elements = component.find('channelListItem');
        if (elements.length){} else {
            elements = [elements]
        }
        var channelModal  = component.find('manageChannelsModal');
        if (channelModal.length){} else {
            channelModal = [channelModal]
        }
        var originalChannelName;
        var edError = helper.getElementByAttribute(component.find('renameSpanError'), "data-channel-id", channelId);
        var inputs = component.find("fieldChannel");
        var editInput = helper.getElementByAttribute(inputs, "id", "field"+channelId);
        var hiddenName = helper.getElementByAttribute(component.find('hiddenName'), "data-channel-id", channelId);
        if(hiddenName){
            originalChannelName = hiddenName.innerText;
    		$A.util.addClass(edError, 'hide');
    		$A.util.removeClass(edError, 'show');
        }
        if(action == "info"){
            $A.util.addClass(infoBlock, 'show');
        	$A.util.addClass(removeBlock, 'hide');
            $A.util.addClass(editBlock, 'hide');
            for(var i=0; i<elements.length; i++) {
                $A.util.removeClass(elements[i], 'disabled');
            }
        }else{
            if(editInput){
                editInput.value = originalChannelName;
            }
			$A.util.removeClass(infoBlock, 'show');
            $A.util.addClass(infoBlock, 'hide');
            if (action == "edit") {
                $A.util.addClass(removeBlock, 'hide');
                $A.util.removeClass(editBlock, 'hide');
            } else if (action == "remove") {
                $A.util.addClass(editBlock, 'hide');
                $A.util.removeClass(removeBlock, 'hide');
            }
            for(var i=0; i<elements.length; i++) {
                var element = elements[i];
                if(element.getElement().getAttribute("data-channel-id") != channelId){
                    $A.util.addClass(element, 'disabled');
                }
            }
        }
    },
    getElementByAttribute: function(findArr, attrName, value) {
        var result = null;
        if (findArr.length) {
            for(var i=0; i<findArr.length; i++){
                if (findArr[i].getElement().getAttribute(attrName) == value) {
                    result = findArr[i].getElement();
                }
            }
        } else if (findArr && findArr.getElement().getAttribute(attrName) == value){
            result = findArr.getElement();
        }
        return result;
    }
})