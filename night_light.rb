require 'gpio'
require 'hue'

class NightLight
  OPERATING_HOURS = (0..5).to_a.unshift(23) # 11pm-6am
  NIGHT_LIGHTS = [3,2,1,5,6] # light numbers to turn on
  DEFAULT_SETTINGS = {
    brightness: 144,
    color_temperature: 467,
    hue: 13088,
    saturation: 213,
  }

  def self.toggle(state=:on)
    return false unless self.is_operating_hours? || state == :off
    self.hue_client.lights.each do |light|
      next unless self.is_nightlight? light
      case state
      when :on
        light.brightness = 25
        light.color_temperature = 500
        light.hue = 13236
        light.saturation = 226
        light.on!
      when :off
        light.off!
        light.brightness = DEFAULT_SETTINGS[:brightness]
        light.color_temperature = DEFAULT_SETTINGS[:color_temperature]
        light.hue = DEFAULT_SETTINGS[:hue]
        light.saturation = DEFAULT_SETTINGS[:saturation]
      end

      sleep 0.4
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
    motion = GPIO::MotionDetector.new(pin: 24)
    loop do
      motion_detected if motion.detect && !@sleeping
    end
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
