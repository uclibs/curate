/*
This file is to fix #588, adds validations to any input field within form with the class of 'validate-me'.

you can add the class to any new work form in the _form_required_information template

*/

//Check if the input is null or a single space. If valid return true, return false otherwise.
function isValid(requiredField) {
	if (requiredField === null || requiredField.match(/^\s*$/)) {
 		return false;
 	}
 	else {
		return true;
 	}
}

function stripWhiteSpace(requiredField) {
	requiredField.replace('\v', ' ')
}

function validateAllFields() {
	//collect all elements with the class 'validate-me' into array
	var inputs = document.getElementsByClassName('validate-me');
	var valid = true;
	//cycle through and validate all of the input values, not the elements themselves.
	for (var i = 0; i < inputs.length; i+=1) {
		if(!isValid(inputs[i].value)) {
			//display error message
			document.getElementById("invalid-input-alert").style.visibility = "visible";
			valid = false;
			break;
		}
		stripWhiteSpace(inputs[i].value);
	}
	if (valid) {
		var spinner = new Spinner().spin();
		$('#spinner-wrapper').append(spinner.el);
		document.forms['new_input_form'].submit();
		return true;
	}
	else return false;
}
