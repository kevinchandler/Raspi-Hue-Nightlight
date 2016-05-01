require 'gpio' # https://github.com/klappy/gpio
require 'hue' # https://github.com/soffes/hue

class NightLight
  OPERATING_HOURS = (0..5).to_a.unshift(23) # 11pm-6am
  ON_DURATION = 5.minutes

  def self.on
    if self.is_operating_hours?
      puts 'turning on lights'

      # turn on lights
      sleep ON_DURATION
      self.off
    end
  end

  def self.off
    puts 'turning off lights'
    # turn off lights
  end

  def self.is_operating_hours?
    OPERATING_HOURS.include? Time.now.hour
  end
end



class MotionSensor
  def self.on
    motion = GPIO::MotionDetector.new(pin: 18)
    self.motion_detected if motion.detect
  end


  def self.motion_detected
    puts 'motion detected'
    NightLight.on
  end
end


MotionSensor.on
