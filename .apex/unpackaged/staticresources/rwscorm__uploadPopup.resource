		jQuery.noConflict();
		
		function urlParam (name, url) {
			if (!url) {
				url = window.location.href;
			}
			var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(url);
			if (!results) {
				return 0;
			}
			return results[1] || 0;
		}
		
		jQuery(document).ready(function() {
			jQuery('head').append('<link rel="stylesheet" href="/resource/scormanywhere__SCORM_Library/css/upload-lightbox.css" type="text/css" />');
			jQuery('<div class="b-overlay" style="display:none;"></div><div class="b-lightbox" style="display:none;"><div class="b-title-bar"><div class="b-close-btn"><a href="#">Close</a></div><div class="b-title">Upload Course</div></div><div class="b-content"><div class="b-scroller"><span id="j_id0:j_id29:upload_frame"><span id="upload_iframe_here"></span></span><div id="upload_success" style="width: 100%; height: 410px; text-align: center;"><span style="font-size: 1.5em; font-weight: bold;">Congratulations!!!</span><br /><span style="font-size: 1.2em;">Your upload is passed</span></div><div id="Course_create" style="width: 100%; height: 410px; text-align: center;"><span style="font-size: 20px;"> Creating course, please wait...</span><br /></div></div></div></div>').appendTo("body");
			overlay = jQuery('.b-overlay');
			lightbox = jQuery('.b-lightbox');
			closelightbox = jQuery('.b-lightbox .b-close-btn');

			closelightbox.click(function() {
				hideLightBox();
			});

			if (urlParam('uploadId') && 'false' == 'false') {
				//if uploadId in get params create Courses and manifests
				//createCourse();
				showLightboxLayoutCourseCreateInProgress();

			}
		});
		
		function showLightBox() {
			lightbox.fadeIn('fast');
			overlay.fadeIn('fast');
		}
		
		function hideLightBox() {
			lightbox.fadeOut('fast');
			overlay.fadeOut('fast');
		}
		 
		
		
		function showLightboxLayoutCourseCreateInProgress() {
			showFormCourseCreateInProgress();
			showLightBox();
		}
		
		function showLightboxLayoutNewUpload() {
			showFormNewUpload();
			showLightBox();
		}
		
		function showFormCourseCreateInProgress() {
			jQuery('[id*="upload_success"]').hide();
			jQuery('[id*="upload_frame"]').hide();
			jQuery('[id*="Course_create"]').show();
		}
		
		function showFormNewUpload() {
			jQuery('[id*="upload_success"]').hide();
			jQuery('[id*="upload_frame"]').show();
			jQuery('[id*="Course_create"]').hide();
		}
		
		var iframe = document.createElement('iframe');
		
		function createIFrame(frameURL) {
			if(document.getElementById('createdIframe') == null) {
				iframe.src = frameURL;
				iframe.width = "100%";
				iframe.id = 'createdIframe';
				iframe.height="600";
				iframe.scrolling="no";
				iframe.frameBorder=0;
				iframe.setAttribute("frameBorder", "0");
				iframe.setAttribute("id", "createdIframe");
				document.getElementById('upload_iframe_here').appendChild(iframe);
		 }
		}		
