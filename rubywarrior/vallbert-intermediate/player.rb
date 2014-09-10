class Player

  require 'pry'

  FIELD = { enemies:[], bound_enemies: [], captives: [], empty: [] }

  def play_turn(warrior)
    look_around warrior unless @looked
    evaluate_situation warrior
  end

  def look_around(warrior)
    @looked = true

    [:forward, :right, :backward, :left].each do |direction|
      feeling = warrior.feel direction
      FIELD[:enemies].push  direction if feeling.enemy?
      FIELD[:captives].push direction if feeling.captive?
    end
  end

  def evaluate_situation(warrior)
    enemies = FIELD[:enemies].count
    captives = FIELD[:captives].count

    if enemies > 0
      neutralize_enemies warrior
    elsif captives > 0
      rescue_captives warrior
    else
      advance warrior
    end
  end

  def neutralize_enemies(warrior)
    direction = FIELD[:enemies].pop

    warrior.bind! direction
    FIELD[:bound_enemies].push direction
  end

  def rescue_captives(warrior)
    direction = FIELD[:captives].pop
    warrior.rescue! direction
  end

  def advance(warrior)
    direction = warrior.direction_of_stairs
    feeling = warrior.feel direction

    if feeling.empty?
      move warrior, direction
      clean_field
    elsif feeling.enemy?
      warrior.attack! direction
    elsif feeling.captive?
      evaluate_captive warrior, direction
    end
  end

  def evaluate_captive(warrior, direction)
    if FIELD[:bound_enemies].include?(direction)
      warrior.attack!(direction)
      FIELD[:bound_enemies].delete(direction)
    else
      warrior.rescue!(direction)
    end
  end

  def move(warrior, direction)
    captive = looking_for 'Captive', warrior

    if captive
      captive_dir = warrior.direction_of captive
      direction = captive_dir if direction != captive_dir
    end

    warrior.walk! direction
  end

  def clean_field
    [:enemies, :bound_enemies, :captives, :empty].each do |type|
      FIELD[type].clear
    end
    @looked = false
  end

  def looking_for(type, warrior)
    chosen = false

    warrior.listen.each do |space|
      if type == space.to_s
        chosen = space
        break
      end
    end

    chosen
  end
end
