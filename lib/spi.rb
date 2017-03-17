require "spi/version"
require "spi/driver"

class SPI

  class SPIException < Exception; end

  attr_reader :driver

  def initialize (args={})

    if args[:driver].nil?
      require "spi/driver/spidev"
      @device = args[:device] or raise SPIException, "args[:device] required"
      @driver=SPI::Driver::SPIdev.new(device: '/dev/spidev32766.0')
    end


    def xfer(data,length=0)
      @driver.xfer(data,length)
    end

  end
end
