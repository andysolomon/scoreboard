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
redUndo = function () {
  $.ajax({method: 'PUT', url: '/red_undo', data: ''});
}
blueUndo = function () {
  $.ajax({method: 'PUT', url: '/blue_undo', data: ''});
}
newGame = function () {
  $.ajax({method: 'PUT', url: '/new_game', data: '' });
}

$(function() {
  $('.action-bar__item__reset').on('click', resetScores);
})
$(function() {
  $('.action-bar__item__new-game').on('click', newGame);
})
$(function() {
  $('.action-bar__item__blue-score--increment').on('click', blueScores);
})
$(function() {
  $('.action-bar__item__red-score--increment').on('click', redScores);
})
$(function() {
  $('.action-bar__item__blue-score--decrement').on('click', blueUndo);
})
$(function() {
  $('.action-bar__item__red-score--decrement').on('click', redUndo);
})
