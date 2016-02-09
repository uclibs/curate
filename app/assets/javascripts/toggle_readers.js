//This is used to display and to hide the 'readers' section
var toggle_readers = function() {
  if( $('#visibility_restricted').is(':checked') || $('#visibility_embargo').is(':checked') ) {
    $('.set-readers').show();
  } else {
    $('.set-readers').hide();
  }
  $('[id^="visibility_"]').on('change', function(event) {
    if( $('#visibility_restricted').is(':checked') || $('#visibility_embargo').is(':checked') ) {
      $('.set-readers').show();
    } else {
      $('.set-readers').hide();
    }
  });
};

var set_reader_form = function() {

};

$(document).ready(toggle_readers);
$(document).on('page:load', toggle_readers);
