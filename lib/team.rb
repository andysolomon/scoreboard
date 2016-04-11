class Teams
  include Redis::Objects
  list :teams
  set :allteams

  attr_reader :id

  # TODO
  # Remove logic into separate methods
  def initialize(name_one = nil)
    # Execute this block when the array has two elements
    if teams.count == 2
      # Execute block if name being passed in is unique
      if (allteams.member?(name_one) == false)
        teams << name_one
        # Add the new element to the array and remove the oldest
        teams.shift
      end
      # Execute block if the parameter passed in is not empty. Prevents empty data in sets.
      if (name_one != nil)
        # Add the passed in value to persisted list of teams if unique.
        allteams << name_one
      end
    end
    # Execute block if the parameter passed in is not empty. Prevents empty data in sets.
    if (name_one != nil)
      # Execute this block when the array has only one element
      if teams.count < 2
        # Execute block if name being passed in is unique
        if (allteams.member?(name_one) == false)
          teams << name_one
        end
        allteams << name_one
      end
    end
  end

  # Not being used at the moment
  def add_player(player)
    self.teams << player
    allteams << name_one
  end

  # This is required for Redis
  def id
    1
  end

end
