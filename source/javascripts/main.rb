require 'fron'

module Kernel
  def interval(ms = 0)
    `setInterval(function(){#{yield}},#{ms})`
  end
end

# Neko
class Neko < Fron::Component
  STATES = {
    hungry: {
      method: :eat,
      probability: 0.1,
      duration: 1,
      score: 10
    },
    sleep: {
      method: :wakeup,
      probability: 0.2,
      duration: 2,
      score: 0
    },
    playful: {
      method: :play,
      probability: 0.5,
      duration: 3,
      score: 10
    },
    sick: {
      method: :heal,
      probability: 0.05,
      duration: 4,
      score: 10
    },
    idle: {
      method: :scratch,
      score: 0
    }
  }

  def initialize
    super
    @health = 100

    @state = :idle
    @state_started_at = nil

    interval 1000 do tick end
  end

  def action=(value)
    self[:action] = value
  end

  def tick
    return if dead?

    if idle?
      state, _ = next_state
      if state
        @start_time = Time.now
        @state = state
        puts "Next state: #{state}"
      end
    else
      diff = Time.now - @start_time
      end_state if diff > STATES[@state][:duration]
    end

    self[:action] = @state
  end

  def end_state
    @health -= STATES[@state][:score]
    puts "Failed: health is now #{@health}"
    if @health > 0
      idle
    else
      die
    end
  end

  def die
    @state = :dead
    puts 'Your cat is dead!'
  end

  def idle
    @state = :idle
    @start_time = nil
  end

  def next_state(random = rand)
    STATES.find do |_, state|
      state[:probability] && state[:probability] > random
    end
  end

  def dead?
    @state == :dead
  end

  def idle?
    @state == :idle
  end
end

DOM::Document.body << Neko.new
