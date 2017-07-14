({
    closeAttachModal : function (component, event, helper) {
        component.showModal("theAttachModal", false);
        var cmpEvent = component.getEvent("setChannelsEvent");
        cmpEvent.fire();
    },
    closeRemoveModal : function (component, event, helper) {
        component.showModal("theRemoveModal", false);
        var cmpEvent = component.getEvent("setChannelsEvent");
        cmpEvent.fire();
    },
    closeChannelModal : function (component, event, helper) {
        component.showModal("theChannelsModal", false);
        helper.resetChannelList(component, helper);
    },
    removeMediaFromChan : function (component, event, helper){
        var mediaId = event.target.getAttribute('data-media-id');

		var cmpEvent = component.getEvent("removeMediaFromChanEvent");
        cmpEvent.setParams({
        	"mediaId" : mediaId
        });
        cmpEvent.fire();
    },
    showHandler : function (component, event, helper) {
        helper.showHandler(component, helper, event.target.getAttribute('data-channel-id'), event.target.getAttribute('data-action'));
    },
    addMediaToChan : function (component, event, helper){
        var channelId = '';
        var newChannelName = '';
        var mediaId;
        var attr;
        if(event.target.tagName == "DIV"){
            mediaId = event.target.getAttribute('data-media-id');
            var channelId = event.target.getAttribute('data-channel-id');
        } else{
            var attr = event.target.getAttribute('data-input-id');
            newChannelName = component.get("v.newChannelName");
            mediaId = attr.substring(2, attr.length);
        }

        var cmpEvent = component.getEvent("addMediaToChannelEvent");
        cmpEvent.setParams({
            "channelId" : channelId,
        	"mediaId" : mediaId,
            "channelName" : newChannelName.trim()
        });
        cmpEvent.fire();

        if(event.target.tagName == "BUTTON"){
            component.showModal("theAttachModal", false);
            component.set("v.newChannelName", "");
        }
    },
    deleteChannel : function (component, event, helper){
        var attr = event.target.getAttribute('data-channel-id');

        var cmpEvent = component.getEvent("deleteChannelEvent");
        cmpEvent.setParams({
            "channelId" : attr
        });
        cmpEvent.fire();
    },

    renameChannel : function (component, event, helper){
        var attr = event.target.getAttribute('data-input-id');
        var elemId = event.target.getAttribute('data-element-id');
        var channelId = event.target.getAttribute('data-channel-id');
        var channelModal  = component.find('manageChannelsModal').getElement();

        var inputs = component.find("fieldChannel");
        var editInput = helper.getElementByAttribute(inputs, "id", attr);
        var inputName = editInput.value;
        var channels = component.get("v.channel");
        var isDuplicateName = false;
        if (inputName.trim()) {
            for (var i = 0; i < channels.length; i++) {
                if (channels[i].name == inputName.trim() && channels[i].id != channelId) {
                    isDuplicateName = true;
                    break;
                }
            }
        }
        console.log(isDuplicateName);

        var edError = helper.getElementByAttribute(component.find('renameSpanError'), "data-channel-id", channelId);
        if (inputName.trim()) {
            if (!isDuplicateName) {
                $A.util.removeClass(edError, 'show');
                $A.util.addClass(edError, 'hide');

                var cmpEvent = component.getEvent("renameChannelEvent");
                cmpEvent.setParams({
                    "channelId" : channelId,
                    "channelName" : inputName.trim()
                });
                cmpEvent.fire();
            } else {
                $A.util.removeClass(edError, 'hide');
                $A.util.addClass(edError, 'show');
            }
        } else {
            $A.util.removeClass(edError, 'show');
            $A.util.addClass(edError, 'hide');
            editInput.placeholder = $A.get("$Label.vtui.Channel_Name_Placeholder");
            editInput.value = "";

        }
    },
    addMediaToChanByEnter : function(component, event, helper){
        if (event.keyCode == 13) {
            component.find('addChanelByEnter').getElement().click();
        } else {
            return;
        }
    },
    isOpenModalHandler: function(component, event) {
        var params = event.getParam('arguments');
        var modalId = null;
        var result = null;
        if (params) {
            modalId = params.modalId;
            if (modalId == "theRemoveModal") {
                result = component.get("v.showRemoveModal");
            } else if (modalId == "theAttachModal") {
                result = component.get("v.showAttachModal");
            } else if (modalId == "theChannelsModal") {
                result = component.get("v.showChannelsModal");
            }
        }
        return result;
    },
    showModalHandler: function(component, event) {
        var params = event.getParam('arguments');
        var modalId = null;
        var show = null;
        if (params) {
            modalId = params.modalId;
            show = params.show;
            if (modalId == "theRemoveModal") {
                component.set("v.showRemoveModal", show);
            } else if (modalId == "theAttachModal") {
                component.set("v.showAttachModal", show);
            } else if (modalId == "theChannelsModal") {
                component.set("v.showChannelsModal", show);
            }
        }
    }
})