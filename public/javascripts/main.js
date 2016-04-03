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
  $('.action-bar__item__reset').on('click', resetScores);
})
$(function() {
  $('.action-bar__item__blue-score').on('click', blueScores);
})
$(function() {
  $('.action-bar__item__red-score').on('click', redScores);
})
