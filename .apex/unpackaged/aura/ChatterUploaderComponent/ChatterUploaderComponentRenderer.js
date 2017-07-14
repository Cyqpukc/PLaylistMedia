({
    afterRender: function (cmp, helper) {
        this.superAfterRender();
		//Class for desktop button inserting       
        var Button = function (id, label) {
            var container = document.createElement('span');
            container.className = 'cke_toolbar';
            container.id = id;
                container.appendChild((function () {
                    var span = document.createElement('span');
                    span.className = 'cke_voice_label';
                    span.innerHTML = label;
                    return span;
                })());
                container.appendChild((function () {
                    var span = document.createElement('span');
                    span.className = 'cke_toolbar_start';
                    return span;
                })());
                container.appendChild((function () {
                    var span = document.createElement('span');
                    span.className = 'cke_toolgroup';
                    span.appendChild((function () {
                        var link = document.createElement('a');
                        link.className = 'cke_button cke_button__image';
                        link.title = label;
                        link.appendChild((function(){
                            var span = document.createElement('span');
                            span.className = 'cke_button_icon';
                            span.innerHTML = '&nbsp;';
                            return span;
                        })());
                        return link;
                    })());
                    return span;
                })());
                container.appendChild((function () {
                    var span = document.createElement('span');
                    span.className = 'cke_toolbar_end';
                    return span;
                })());        
                return container;
        }
        var timer = setInterval(function () {
				//CKEditor insert
            	var instance;
                for(var instanceName in CKEDITOR.instances) {
                    instance = CKEDITOR.instances[instanceName]
                }
                instance.addCommand("uploadClick", {
                	exec: function(edt) {
                    	document.querySelector('#uploadCourseChatterBtn1').click();
                    }
                });
            	//This is not working
            	instance.ui.addButton( 'Video', {
                    label: 'Video',
                    command: 'uploadClick',
                    toolbar: 'basicstyles'
                } );
            
            	var isTablet = $A.get('$Browser.isTablet');
            	var isPhone = $A.get('$Browser.isPhone');
            	var isMobile = isTablet || isPhone;
                if (isMobile) {
					//Mobile (innerHTML) inserting. This work only on old release
                    var bottomBar = document.querySelector('.forceChatterPublisherPresentationDesktop .forceChatterPublisherAttachments ul.cuf-attachmentsList');
                    if(bottomBar !== null) {
                        clearInterval(timer);
                        bottomBar.innerHTML += 
                            '<li class="cuf-attachmentsItem" data-aura-rendered-by="3:314;a">'
                        		+ '<button id="cx244_attach" class="slds-button slds-button--icon cuf-publisherAttachmentButton cuf-publisherAttachmentGroup uiButton" type="button" data-aura-rendered-by="17:314;a" data-aura-class="uiButton">'
                                	+ '<span class="assistiveText" data-aura-rendered-by="21:314;a">Video</span>'
                                    + '<div class="cuf-Icon" data-aura-rendered-by="7:314;a">'
                                    	+ '<span class="icon-fallback-text forceIcon" aria-hidden="true" data-icon="" data-key="attach" data-aura-rendered-by="11:314;a" data-aura-class="forceIcon">'
                                        	+ '<span class="icon icon-key" data-aura-rendered-by="12:314;a"></span>'
                                        + '</span>'
                                    	+ '<span class="newAssistiveText forceIcon" data-aura-rendered-by="13:314;a" data-aura-class="forceIcon"></span>'
                                    + '</div>'
                                + '</button>'
                            + '</li>';
                        var button = document.querySelector('#cx244_attach');
                        button.addEventListener('click', function () {
                            document.querySelector('#uploadCourseChatterBtn1').click();
                        });
                    }
                } else {
                    //Desktop (js) inserting. Working only on desktop
                    var textEditor = document.querySelector('.forceChatterMessageBodyInputRichTextArea span.cke_toolbox');
                    if(textEditor !== null) {
                        clearInterval(timer);
                        var button = new Button('cx244', 'Video');
                        button.addEventListener('click', function () {
                            document.querySelector('#uploadCourseChatterBtn1').click();
                        });
                        if (document.querySelectorAll('#cx244').length < 1) {
                            textEditor.appendChild(button);
                        }
                        var buttonIcon = document.querySelector('#cx244 .cke_toolgroup .cke_button.cke_button__image .cke_button_icon');
                        buttonIcon.style.backgroundImage = "url('" + ((helper.getPrefix()) ? "/" + helper.getPrefix() + "/" : "/") + "resource/video_icon')";
                    }
                }
        },1000);
    }
})