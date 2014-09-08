class Player
  def play_turn(warrior)
    direction = warrior.direction_of_stairs
    watch_battlefield warrior, direction
  end

  def watch_battlefield(warrior, direction)
    feeling = warrior.feel direction

    if feeling.enemy?
      warrior.attack! direction
    else
      warrior.walk! direction
    end
  end
end
