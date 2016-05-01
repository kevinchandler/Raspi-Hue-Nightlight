require 'gpio' # https://github.com/klappy/gpio
require 'hue' # https://github.com/soffes/hue

class NightLight
  OPERATING_HOURS = (0..5).to_a.unshift(23) # 11pm-6am
  NIGHT_LIGHTS = (1..6).to_a  # light numbers to turn on

  def self.toggle(state=:on)
    return false unless self.is_operating_hours? || state == :off
    self.hue_client.lights.each do |light|
      next unless self.is_nightlight? light
      case state
      when :on
        light.on!
      when :off
        light.off!
      end
    end
  end

  def self.is_nightlight?(light)
    NIGHT_LIGHTS.include? light.id.to_i
  end

  def self.is_operating_hours?
    OPERATING_HOURS.include? Time.now.hour
  end

  def self.hue_client
    Hue::Client.new
  end

end


class MotionSensor
  SLEEP_DURATION = 150 # 2.5 minutes in seconds

  def initialize
    @sleeping = false
  end

  def on
    motion = GPIO::MotionDetector.new(pin: 18)
    motion_detected if motion.detect && !@sleeping
  end

  def motion_detected
    on = NightLight.toggle :on
    @sleeping = true if on
    sleep SLEEP_DURATION
    off = NightLight.toggle :off
    @sleeping = false if off
  end
end

sensor = MotionSensor.new
sensor.on
