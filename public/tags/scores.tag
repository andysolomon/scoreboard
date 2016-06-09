<scores>
  <div class="scores">
    <div id="blue-score">
      <span class="name">{ players.blue.name }</span>
      <span class="score">{ players.blue.score }</span>
      <span class="games">{ players.blue.games }</span>
      <span class="serve"><a href="/menu"><img class={ show: players.blue.serve } src="/images/bat.svg" alt="service"></a></span>
    </div>
    <div id="red-score">
      <span class="name">{ players.red.name }</span>
      <span class="score">{ players.red.score }</span>
      <span class="games">{ players.red.games }</span>
      <span class="serve"><a href="/menu"><img class={ show: players.red.serve } src="/images/bat.svg" alt="service"></a></span>
    </div>
  </div>
  <script>

    this.players = opts.players;

    channel.bind('update_scores', function(data) {
      this.players = data;
      var score = "";
      if (this.players.blue.score >= 20 && this.players.red.score >= 20)
         score = "change serve!! ";
      else if ((this.players.blue.score + this.players.red.score) % 5 == 0)
         score = "change serve!! ";
      if (this.players.blue.serve) 
         score = score + this.players.blue.score + " to " + this.players.red.score;
      else 
         score = score + this.players.red.score + " to " + this.players.blue.score; 
      responsiveVoice.speak(score);
      this.update();
    }.bind(this));

  </script>
</scores>
