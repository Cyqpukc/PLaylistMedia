({
	performTabs : function(component) {
        var tabs = component.find("search-tab");
        var activeTabName = component.get("v.activeTab").toString();
        for (var i = 0; i < tabs.length; i++) {
            var tab = tabs[i];
            if (tab != null) {
                var tabName = tab.getElement().dataset.tab.toString();
                if (tabName == activeTabName) {
                	$A.util.addClass(tab, "active");
                } else if ($A.util.hasClass(tab, 'active')) {
                    $A.util.removeClass(tab, 'active');
            	}
            }
        }
	},
    loadContentActiveTab : function(component) {
        switch (component.get("v.activeTab").toString()) {
            case 'videos':
                this.getVideos(component);
                break;
            case 'articles':
                this.getArticles(component);
                break;
        }
    },
    getArticles : function(component) {
        this.getContent(component, 'articles', 'getArticles');
    },
    getVideos : function(component) {
        this.getContent(component, 'videos', 'getVideos');
    },
    getContent : function(component, tabName, controllerMethodName) {
        var searchString = component.get("v.searchString");
        var topicId = component.get("v.topicId");
        var isTopicSearch = topicId.length > 0 && topicId != 'All';

        component.set("v." + tabName, []);

        if (searchString.length <= 100) {
            var a = component.get("c." + controllerMethodName);

            component.set("v.isShow", false);
            component.set("v.isLargeSearch", false);

            a.setParams({"searchString" : searchString, "isTopicSearch" : isTopicSearch, "topicId" : topicId});
            a.setCallback(this, function(action) {
                if (component.isValid() && action.getState() === "SUCCESS") {
                    var response = action.getReturnValue();
                    if (response) {
                        component.set("v." + tabName, response);
                        component.set("v.isShow", true);
                    } else {
                        $A.log('Invalid response');
                    }
                } else {
                    $A.log('State: ' + action.getState());
                }
            });
            $A.enqueueAction(a);
        } else {
            component.set("v.isLargeSearch", true);
            component.set("v.isShow", true);
        }
    },
    getEventElement : function(event) {
        return event.srcElement ? event.srcElement : event.target;
    }
})