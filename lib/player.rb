class Player
  include Redis::Objects

  attr_reader :id

  value :name
  counter :score
  counter :games

  def initialize(id)
    @id = id
  end

  def has_beaten(player)
    (self.score.value > 20 && self.score.value > player.score.value + 1) || (self.score.value >= 11 && player.score.value == 0)
  end

  def attributes
    { name: self.name.value,
      score: self.score.value,
      games: self.games.value }
  end
end
