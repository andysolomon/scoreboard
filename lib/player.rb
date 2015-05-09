class Player
  attr_reader :score, :games, :name

  def initialize(name)
    @name = name
    @score = 0
    @games = 0
  end

  def has_beaten(player)
    @score > 10 && @score > player.score + 1
  end

  def add_point
    @score += 1
  end

  def add_game
    @games += 1
  end

  def undo_point
    @score -= 1
  end

  def reset_score
    @score = 0
  end

  def reset_games
    @games = 0
  end

  def attributes
    { name: @name,
      score: @score,
      games: @games }
  end
end
