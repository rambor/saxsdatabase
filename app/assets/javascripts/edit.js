$(function() {
  var termini = $('#code_search_code_termini').val();

  $("#found_codes").live("click", function() {
    $.getScript(this.href);
    return false;
  });
// execute search as long as string is less than 6 characters
  
  $("#code_search input").keyup(function() {
    $.get($("#code_search").attr("action"), $("#code_search").serialize(), null, "script");
    return false;
  });
});


$(document).ready(function(){
    var code = document.code_search.search;
    var remaining = document.code_search.remLen1;
    
    function textCounting(field,cntfield,maxlimit) {
      if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
        // Set the value
        // otherwise, update 'characters left' counter
      else
        cntfield.value = maxlimit - field.value.length;
    }

    $('#submitsearch').keydown(function(){textCounting(code, remaining, 5)});
    $('#submitsearch').keyup(function(){textCounting(code, remaining, 5)});
});