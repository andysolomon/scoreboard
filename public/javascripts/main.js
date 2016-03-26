var pusher = new Pusher(pusherKey);
var channel = pusher.subscribe('scores');

resetScores = function () {
  $.ajax({method: 'PUT', url: '/reset_scores', data: ''});
}
redScores = function () {
  $.ajax({method: 'PUT', url: '/red_scores', data: ''});
}
blueScores = function () {
  $.ajax({method: 'PUT', url: '/blue_scores', data: ''});
}

$(function() {
  $('#reset').on('click', resetScores);
})
$(function() {
  $('#blue-scores').on('click', blueScores);
})
$(function() {
  $('#red-scores').on('click', redScores);
})
