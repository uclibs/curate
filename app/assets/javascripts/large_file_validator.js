/* 
Validator to detect and stop files that are too large for our application from being uploaded.

current file size limit: ~3GB. Set maxFileSize to change limit.
*/

var maxFileSize = 3221225472;

$(document).ready(function() {
	//get the file size value from the input
	//run it through the checkFileSizes/checkRemoteFileSizes methods
		//if false pop up error immediately and block the form 
	//end
	var submitButton = $('input[name=commit]');
	var uploadWrapper = $('#upload-form-wrap');
	var browseEverthingWrapper = $('#cloud_resource_urls');
	var contactLink = '<a href="http://scholar.uc.edu/contact_requests/new">Contact Us</a>'
	var errorMessage = '<div class="large-file-error alert alert-error fade in">' + 
	'A file you selected is too large to upload to Scholar@UC via the website.' + '<br/>' + 
	'For files larger than 3 gigabytes plase use the ' + contactLink + ' form to request ' + 
	'alternative ways to add your content to Scholar@UC.' + '</div>';
	
	$('input.file.optional').bind('change', function() {
		if (!checkFileSizes(this.files)) {
			//insert error message next to upload form about file size.
			if ($('.large-file-error').length < 1) {
				uploadWrapper.after(errorMessage);
				submitButton.addClass('input-inactive');
				$('.form-actions').append(errorMessage);
			};
		} else {
			$('.large-file-error').remove();
			submitButton.removeClass('input-inactive');
		};
	});

	$(document).on('click', '.ev-submit', function() {
		browseEverthingWrapper.empty();
		setTimeout(function() {
			var file_elements = browseEverthingWrapper.children();
			if (!checkRemoteFileSizes(file_elements)) {
				if ($('.large-file-error').length < 1) {
					$('#browse').after(errorMessage);
					submitButton.addClass('input-inactive');
					$('.form-actions').append(errorMessage);
				};
			} else {
				$('.large-file-error').remove();
				submitButton.removeClass('input-inactive');
			};
		}, 100);
		
	});
	
});

function checkFileSizes(fileList) {
	for (var i = 0; i < fileList.length; i++) {
		if (checkFileSize(fileList[i].size)) {
			return false;
		};
	};
	return true;
};

function checkRemoteFileSizes(fileList) {
	for (var i=0; i<fileList.length; i++) {
		if (fileList[i].name.includes('file_size')) {
			if (checkFileSize(fileList[i].value)) {
				return false;
			};
		};
	};
	return true;
};

function checkFileSize(fileSize) {
	if (fileSize > maxFileSize) {
		return true;
	};
	return false;
};
