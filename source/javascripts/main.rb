require 'fron'

module Kernel
  def interval(ms = 0)
    `setInterval(function(){#{yield}},#{ms})`
  end
end

class Numeric
  def clamp(min, max)
    [[self, max].min, min].max
  end
end

# Neko
class Neko < Fron::Component
  STATES = {
    hungry: {
      method: :eat,
      probability: 0.1,
      duration: 10,
      fail_score: 10,
      success_score: 5
    },
    sleep: {
      method: :wakeup,
      probability: 0.2,
      duration: 10,
      fail_score: 0,
      success_score: 0
    },
    playful: {
      method: :play,
      probability: 0.5,
      duration: 10,
      fail_score: 4,
      success_score: 10
    },
    sick: {
      method: :heal,
      probability: 0.05,
      duration: 10,
      fail_score: 10,
      success_score: 0
    },
    idle: {
      method: :scratch,
    }
  }

  attr_reader :health

  STATES.each do |key, state|
    define_method state[:method] do
      return unless @state == key
      resolve_state
    end
  end

  # Initializes the neko
  def initialize
    super
    @health = 100
    idle
  end

  def tick
    return if dead?

    if idle?
      state, _ = next_state
      if state
        @start_time = Time.now
        set_state state
        puts "Next state: #{state}"
      end
    else
      diff = Time.now - @start_time
      end_state if diff > STATES[@state][:duration]
    end

  end

  def set_state(state)
    @state = state
    self[:action] = state
    @health = @health.clamp(0, 100)
    trigger 'change'
  end

  def resolve_state
    @health += STATES[@state][:success_score]
    puts 'Success...'
    idle
  end

  def end_state
    @health -= STATES[@state][:fail_score]
    puts "Failed: health is now #{@health}"
    if @health > 0
      idle
    else
      die
    end
  end

  # Gets the next state from random number
  #
  # @param random [Float] The random number
  #
  # @return [Array] The state as an array [key, data]
  def next_state(random = rand)
    STATES.find do |_, state|
      state[:probability] && state[:probability] > random
    end
  end

  def die
    set_state :dead
    puts 'Your cat is dead!'
  end

  def idle
    set_state :idle
    @start_time = nil
  end

  def dead?
    @state == :dead
  end

  def idle?
    @state == :idle
  end
end

class Main < Fron::Component
  component :neko, Neko
  component :health, 'div'

  Neko::STATES.each do |key, state|
    component :key, "button[action=#{state[:method]}] #{state[:method]}"
  end

  on :click, :button, :action
  on :change, :render

  def action(event)
    @neko.send event.target[:action]
  end

  def render
    @health.text = @neko.health
  end

  def initialize
    super
    interval 1000 do
      @neko.tick
    end
  end
end
DOM::Document.body << Main.new
