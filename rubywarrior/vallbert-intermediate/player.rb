class Player

  require 'pry'

  FIELD = { enemies:[], bound_enemies: [], captives: [], empty: [] }

  def play_turn(warrior)
    @warrior = warrior
    @direction ||= warrior.direction_of_stairs

    look_around unless @looked
    evaluate_situation
  end

  def look_around
    @looked = true

    [:forward, :right, :backward, :left].each do |direction|
      feeling = @warrior.feel direction
      FIELD[:enemies].push  direction if feeling.enemy?
      FIELD[:captives].push direction if feeling.captive?
    end
  end

  def evaluate_situation
    enemies = FIELD[:enemies].count
    captives = FIELD[:captives].count

    if @reloading_health
      reload_health
    elsif enemies > 0
      neutralize_enemies
    elsif captives > 0
      rescue_captives
    else
      advance
    end
  end

  def neutralize_enemies
    @direction = FIELD[:enemies].pop

    if FIELD[:enemies].length == 0
      attack!
    else
      bind!
    end
  end

  def rescue_captives
    direction = FIELD[:captives].pop
    @warrior.rescue! direction
  end

  def advance
    feeling = @warrior.feel @direction

    if feeling.empty?
      move
    elsif feeling.enemy?
      attack!
    elsif feeling.captive?
      evaluate_captive
    elsif feeling.wall?
      reset_direction
    end
  end

  def evaluate_captive
    if FIELD[:bound_enemies].include?(@direction)
      attack!
      FIELD[:bound_enemies].delete(@direction)
    else
      @warrior.rescue! @direction
    end
  end

  def move
    captive = looking_for 'Captive'

    if captive
      captive_dir = @warrior.direction_of captive
      ensure_direction captive_dir
    end

    @warrior.feel(@direction).empty? ? walk! : advance
  end

  def reset_direction
    @direction = @warrior.direction_of_stairs
    move
  end

  def clean_field
    [:enemies, :bound_enemies, :captives, :empty].each do |type|
      FIELD[type].clear
    end
    @looked = false
  end

  def looking_for(type)
    chosen = false

    @warrior.listen.each do |space|
      if type == space.to_s
        chosen = space
        break
      end
    end

    chosen
  end

  def ensure_direction(captive_dir)
    @direction = captive_dir if @direction != captive_dir
    @direction = find_free_space if @warrior.feel(@direction).stairs?
  end

  def find_free_space
    [:forward, :right, :backward, :left].each do |direction|
      feeling = @warrior.feel(direction)
      return direction if feeling.empty? && !feeling.stairs?
    end
  end

  def walk!
    @warrior.walk! @direction
    clean_field
  end

  def step_back!
    @direction = find_free_space
    @reloading_health = true
    walk!
  end

  def rest!
    @warrior.rest!
  end

  def attack!
    status = health_status
    if status == :really_injured
      step_back!
    else
      @warrior.attack! @direction
    end
  end

  def bind!
    @warrior.bind! @direction
    FIELD[:bound_enemies].push @direction
  end

  def reload_health
    rest!
    @reloading_health = false if health_status == :full
  end

  def health_status
    case @warrior.health
      when 0..4   then return :really_injured
      when 5..10  then return :injured
      when 11..15 then return :fine
      when 16..19 then return :healthy
      else return :full
    end
  end
end
