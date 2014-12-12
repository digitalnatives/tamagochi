require 'fron'

# Kernel
module Kernel
  # Yields every ms time
  #
  # @param ms [Integer] The interval
  def interval(ms = 0)
    `setInterval(function(){#{yield}},#{ms})`
  end
end

# Numeric
class Numeric
  # Clamps the number between a minimum and maximum value.
  #
  # @param min [Numeric] The minimum value
  # @param max [Numeric] The maximum value
  #
  # @return [Numeric] The clamped value
  def clamp(min, max)
    [[self, max].min, min].max
  end
end

# Neko
class Neko < Fron::Component
  NAMES = %w(blue calico gray holiday valentine)

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
      probability: 0.3,
      duration: 10,
      fail_score: 10,
      success_score: 0
    },
    idle: {
      method: :scratch
    }
  }

  attr_reader :health

  # Define states for methods
  STATES.each do |key, state|
    define_method state[:method] do
      return unless @state == key
      resolve_state
    end
  end

  # Initializes the neko
  def initialize
    super
    self[:name] = NAMES.sample
    @health = 100
    idle
  end

  # Runs on every tick
  def tick
    return if dead?
    state, _ = next_state

    if idle? && state
      @start_time = Time.now
      set_state state
      puts "Next state: #{state}"
    else
      diff = Time.now - @start_time
      end_state if diff > STATES[@state][:duration]
    end
  end

  # Sets the state to the given state
  #
  # @param state [String] The state
  def set_state(state)
    @state = state
    self[:action] = state
    @health = @health.clamp(0, 100)
    trigger 'change'
  end

  # Successfull resolve
  def resolve_state
    @health += STATES[@state][:success_score]
    puts 'Successfull resolve!'
    idle
  end

  # Fail to resolve
  def end_state
    @health -= STATES[@state][:fail_score]
    @health > 0 ? idle : die
    puts "Failed to resolve! Health is now #{@health}!"
  end

  # Gets the next state from random number
  #
  # @param random [Float] The random number
  #
  # @return [Array] The state as an array [key, data]
  def next_state
    STATES.find do |_, state|
      state[:probability] && state[:probability] > rand
    end
  end

  # Kills the neko
  def die
    set_state :dead
    puts 'Your neko is dead!'
  end

  # Sets the neko to idle
  def idle
    set_state :idle
    @start_time = nil
  end

  # Returns if the neko is dead or not.
  #
  # @return [Boolean] The value
  def dead?
    @state == :dead
  end

  # Returns if the neko is idle or not.
  #
  # @return [Boolean] The value
  def idle?
    @state == :idle
  end
end

# Main
class Main < Fron::Component
  component :neko, Neko
  component :health, 'div'

  Neko::STATES.each do |_, state|
    component :key, "button[action=#{state[:method]}] #{state[:method]}"
  end

  on :click, :button, :action
  on :change, :render

  # Sends an action to neko
  #
  # @param event [Event] The event
  def action(event)
    @neko.send event.target[:action]
  end

  # Renders the component
  def render
    @health.text = @neko.health
  end

  # Initializes the component
  def initialize
    super
    interval(1000) { @neko.tick }
  end
end

DOM::Document.body << Main.new
