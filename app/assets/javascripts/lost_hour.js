function calculate_lost_hour(col) {
  var total = 0;
  var number_assignees = $("#lost_hour_table").data("numberAssignees");

  for(var j = 0; j < number_assignees; j++) {
    var value = $($(".assignee-col-" + col)[j]).children().last().val();
    if(value == "") value = 0;
    total += parseInt(value);
  }

  if(col == 0) {
    $("#work-hour-" + col + " input").val(total);
  }
  else {
    $("#lost-hour-" + col + " input").val(total);
    total_lost_hour();
  }
}

function total_lost_hour() {
  var total = 0;
  var work_day = $("#lost_hour_table").data("numberWorkDay");

  for(var i = 1; i < work_day; i++) {
    total += parseInt($("#lost-hour-" + i +" input").val());
  }
  $("#lost-hour-0 input").val(total);
}

$(document).on("change click", "#lost_hour_table td input", function(){
  var col = parseInt($($(this).parent().attr("class").split("-")).last()[0]);
  calculate_lost_hour(col);
  setTotoalRemaining(col);
});

function setTotoalRemaining(col) {
  if(col == 0) return;
  var remainBefore = parseInt($(".log-actual-" + (col - 1)).text());

  var lostHour = parseInt($("#lost-hour-" + col + " input").val());
  var workHour = parseInt($("#work-hour-0" + " input").val());

  var remain = remainBefore + lostHour - workHour;
  $(".log-actual-" + col).text(remain);

  var cells = $('th[class*="log-actual"]');
  for(++col; col < cells.length; col++) {
    $(cells[col]).text(parseInt($(cells[col-1]).text()) - workHour);
  }
}