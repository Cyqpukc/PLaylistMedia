({
    afterRender: function (cmp, helper) {
        var afterRend = this.superAfterRender();
        var tpcId = cmp.get("v.topicId") ? cmp.get("v.topicId") : "All";
        var searchString = tpcId === "All" ? cmp.get("v.searchString") : null;
        $A.createComponent(
            "forceCommunity:resultsList",
            {
                topicId: tpcId,
                searchTerm: searchString,
                showArticleTab: true
            },
            function(newStdSearch){
                var stdSearch = cmp.get("v.stdSearch");
                stdSearch.push(newStdSearch);
                cmp.set("v.stdSearch", stdSearch);
            }
        );
        return afterRend;
    },
    render: function (cmp, helper) {
        var rend = this.superRender();
        helper.performTabs(cmp);
        return rend;
    },
    rerender: function (cmp, helper) {
        var rerend = this.superRerender();
        helper.performTabs(cmp);
        return rerend;
    }
})