class SPI
  module Driver
    # Abstract class for I2CDevice::Driver
    class Base
      include SPI::Driver
    end

    def xfer
      raise NotImplementedError, "xfer needs to be defined per Driver Library"
    end
  end
end
