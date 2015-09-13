class Player
  require 'pry'

  def play_turn(warrior)
    @warrior = warrior
    advance
  end

  def advance
    direction = @warrior.direction_of_stairs
    space = @warrior.feel(direction)

    if space.enemy?
      @warrior.attack!(direction)
    else
      @warrior.walk!(direction)
    end
  end
end
