/*
This file is to fix #588, adds validations to any input field within form with the class of 'no-space'.

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

function validateAllFields() {
	//collect all elements with the class 'no-space' into array
	var inputs = document.getElementsByClassName('no-space');
	var valid = true;
	//cycle through and validate all of the input values, not the elements themselves.
	for (var i = 0; i < inputs.length; i+=1) {
		if(!isValid(inputs[i].value)) {
			//display error message
			document.getElementById("invalid-input-alert").style.visibility = "visible";
			valid = false;
			break;
		}
	}
	if (valid) {
		document.forms['new_work_form'].submit();
		return true;
		//document.forms['new_work_form'].submit();
	}
	else return false;
}