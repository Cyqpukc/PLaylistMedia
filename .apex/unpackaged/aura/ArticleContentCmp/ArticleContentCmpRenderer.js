({
	afterRender: function (component, helper) {
        this.superAfterRender();
        //fix video iframe urls for articles
        		var frames;
                if (document.all) {
                    frames = document.all["iframe"];
                } else {
                    frames = window.document.getElementsByTagName("iframe");
                }
                [].forEach.call(frames, function (fi) {
                    if (!fi.src){
                        if (fi.frameElement.src.indexOf("SCORM_Player") > -1 && fi.frameElement.id == '') {
                            if (fi.frameElement.dataset.changedomain) {} else {
                                var iframeSrc = fi.frameElement.src.substr(fi.frameElement.src.indexOf('/apex/'));
                                if (window.location.href.indexOf('/s/') > -1)
                                {
                                    fi.frameElement.src = window.location.href.substr(0,window.location.href.indexOf('/s/')) + iframeSrc;
                                }
                                else
                                {
                                    fi.frameElement.src = window.location.href.substr(0,window.location.href.indexOf('/article')) + iframeSrc;
                                }
                                fi.frameElement.dataset.changedomain = true;
                            }
                        }
                    } else {
                        if (fi.src.indexOf("SCORM_Player") > -1 && fi.id=='') {
                            if (fi.dataset.changedomain) {} else {
                                var iframeSrc = fi.src.substr(fi.src.indexOf('/apex/'));
                                if (window.location.href.indexOf('/s/') > -1)
                                {
                                    fi.src = window.location.href.substr(0,window.location.href.indexOf('/s/')) + iframeSrc;
                                }
                                else
                                {
                                    fi.src = window.location.href.substr(0,window.location.href.indexOf('/article')) + iframeSrc;
                                }
                                fi.dataset.changedomain = true;
                            }
                        }
                    }

                });
    },
})