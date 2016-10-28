/**
 * This Javascript/JQuery method is used for the population of the creator, college, and department fields
 * when a proxy user is making a deposit on behalf of someone else.  The method gets the selected
 * person on behalf of whom the proxy person is making the deposit and places that person's name in
 * a Creator field and clicks the creator Add button, as well as populating the
 * the college and department fields.
 */

function updateCreators(){

    // Get the selected owner name from the owner control.
    // If it is 'Myself', then pluck the name from the display name on the dropdown menu in the title bar of the page.
    // If 'nothing' was selected, do nothing and return.
    var ownerName = $("[id*='_owner'] option:selected").text();

    if (ownerName == 'Myself') {
        ownerName = $(".user-display-name").text().trim();
    }

    else if (ownerName === "") { return; }

    ownerName = ownerName.split(" ").reverse().join(", ");


    // Put that name into the "Add" Creator control and force a click of the Add button.
    // Note that the last Creator control is always the one into which a new user is entered.
    $('input[id$=_creator]').last().val(ownerName);
    $("div[class*=_creator] .add").click();
}

function updateCollDept(){
    // Get Department and College from owner control.
    var ownerDept = $("[id*='_owner'] option:selected").attr("data-dept");
    var ownerCollege = $("[id*='_owner'] option:selected").attr("data-college");
 
    //Put college and dept values into respective controls
    $('select[id$=_college]').val(ownerCollege);
    $('input[id$=_department]').val(ownerDept);
}

function renderOwnerField() {
  var ownerName = $("[id*='_owner'] option:selected").text();
  var ownerField = $('#owner_editor_field');
  if (ownerName != 'Myself' && ownerName != '') { 
    ownerField[0].value = ownerName;
    ownerField.removeClass('hidden');
  } else { ownerField.addClass('hidden'); }
}
