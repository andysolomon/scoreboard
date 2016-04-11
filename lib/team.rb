class Teams
  include Redis::Objects
  list :teams

  attr_reader :id

  def initialize(name_one = nil)
    if teams.count == 2
      teams << name_one
      teams.shift
    end
    if teams.count < 2
      teams << name_one
    end
  end

  def add_player(player)
    self.teams << player
    puts self.teams
  end

  # This is required for Redis
  def id
    1
  end

end
