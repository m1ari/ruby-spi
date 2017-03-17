require 'spi'

class SPI
  module Driver
    class SPIdev < SPI::Driver::Base
      attr_reader :mode
      attr_reader :bits
      attr_reader :speed

      def initialize(args={})
        #raise SPINoDevice, "No Device specified" if args[:device].nil?
        #raise SPINoDevice, "Device #{args[:device]} not found" unless File.exists?(args[:device])
        puts "Using Device #{args[:device]}"
        @device = File.open(args[:device])
        @mode=getMode
        @bits=getBits
        @speed=getSpeed
      end

      def mode=(mode)
        @device.ioctl(SPI_IOC_WR_MODE(), mode.pack('C'));
        @mode=getMode
      end

      def bits=(bits)
        @device.ioctl(SPI_IOC_WR_BITS_PER_WORD(), bits.pack('C'))
        @bits=getBits
      end

      def speed=(speed)
        @device.ioctl(SPI_IOC_WR_MAX_SPEED_HZ(),[speed].pack('L'))
        @speed=getSpeed
      end

      # TODO accessors for SPI_IOC_WR_LSB_FIRST and SPI_IOC_WR_MODE32


      def xfer(txdata, length=0)
        length = txdata.size if txdata.size > length
        
        # TODO Use the bitstruct gem ?
        # https://rubygems.org/gems/bit-struct/versions/0.15.0
        # Or create a class to wrap access and pack/unpack

        # struct spi_ioc_transfer
        # txdata                  # __u64 (pointer to data)
        rxdata= ' ' * length      # __u64 (pointer to data)

        # length                  # __u32
        speed             = 0     # __u32

        delay_usecs       = 0     # __u16
        bits_per_word     = 0     # __u8
        cs_change         = 0     # __u8
        tx_nbits          = 0     # __u8
        rx_nbits          = 0     # __u8
        pad               = 0     # __u16
  

        # We might need to do something special with the txdata and rxdata pointers to make them 64 bit
        data = [txdata, 0, rxdata, 0, length, speed, delay_usecs, bits_per_word, cs_change, tx_nbits, rx_nbits, pad].pack('PLPLLLSCCCCS')

        require 'pp'
        pp data
        # We're only going to handle one message at a time for now
        @device.ioctl(SPI_IOC_MESSAGE(1),data)

        #rxdata = data.unpack('PPLLSCCCCS')[1]
        return rxdata
    
      end

    private
      # TODO It might be good to generalize these functions, Maybe make a IOCTL class?
      def getMode
        data=[0].pack('C')
        @device.ioctl(SPI_IOC_RD_MODE(), data);
        return data.unpack('C')[0]
      end

      def getBits
        data=[0].pack('C')
        @device.ioctl(SPI_IOC_RD_BITS_PER_WORD(), data);
        return data.unpack('C')[0]
      end

      def getSpeed
        data=[0].pack('L')
        @device.ioctl(SPI_IOC_RD_MAX_SPEED_HZ(),data)
        return data.unpack('L')[0]
      end


      # Functions and Constants based on /usr/include/asm-generic/ioctl.h
      IOC_NONE    = 0x00
      IOC_WRITE   = 0x01
      IOC_READ    = 0x02

      def _IOC(dir, type, nr, size)
        out=0
        out += dir  << (14 + 8 + 8) # 2 bits
        out += size << (     8 + 8) # 14 bits
        out += type << (         8) # 8 bits
        out += nr                   # 8 bits
        return out
      end

      def _IO(type,nr);         _IOC(IOC_NONE,            type, nr, 0); end
      def _IOR(type,nr,size);   _IOC(IOC_READ,            type, nr, size); end
      def _IOW(type,nr,size);   _IOC(IOC_WRITE,           type, nr, size); end
      def _IOWR(type,nr,size);  _IOC(IOC_READ |IOC_WRITE, type, nr, size); end
      
      # Functions and Constants based on /usr/include/linux/spi/spidev.h
      SPI_CPHA       = 0x01
      SPI_CPOL       = 0x02

      MODE0     = (0|0)
      MODE1     = (0|SPI_CPHA)
      MODE2     = (SPI_CPOL|0)
      MODE3     = (SPI_CPOL|SPI_CPHA)

      SPI_CS_HIGH    = 0x04
      SPI_LSB_FIRST  = 0x08
      SPI_3WIRE      = 0x10
      SPI_LOOP       = 0x20
      SPI_NO_CS      = 0x40
      SPI_READY      = 0x80
      SPI_TX_DUAL    = 0x100
      SPI_TX_QUAD    = 0x200
      SPI_RX_DUAL    = 0x400
      SPI_RX_QUAD    = 0x800

      SPI_IOC_MAGIC   = 'k'.ord

      # SPI Definitions based on /usr/include/linux/spi/spidev.h
      # TODO we could also determine these as constants
      # /* Read / Write of SPI mode (SPI_MODE_0..SPI_MODE_3) (limited to 8 bits) */
      def SPI_IOC_RD_MODE;            _IOR(SPI_IOC_MAGIC, 1, 1); end
      def SPI_IOC_WR_MODE;            _IOW(SPI_IOC_MAGIC, 1, 1); end

      # /* Read / Write SPI bit justification */
      def SPI_IOC_RD_LSB_FIRST;       _IOR(SPI_IOC_MAGIC, 2, 1); end
      def SPI_IOC_WR_LSB_FIRST;       _IOW(SPI_IOC_MAGIC, 2, 1); end

      # /* Read / Write SPI device word length (1..N) */
      def SPI_IOC_RD_BITS_PER_WORD;   _IOR(SPI_IOC_MAGIC, 3, 1); end
      def SPI_IOC_WR_BITS_PER_WORD;   _IOW(SPI_IOC_MAGIC, 3, 1); end

      # /* Read / Write SPI device default max speed hz */
      def SPI_IOC_RD_MAX_SPEED_HZ;    _IOR(SPI_IOC_MAGIC, 4, 4); end
      def SPI_IOC_WR_MAX_SPEED_HZ;    _IOW(SPI_IOC_MAGIC, 4, 4); end

      # /* Read / Write of the SPI mode field */
      def SPI_IOC_RD_MODE32;          _IOR(SPI_IOC_MAGIC, 5, 4); end
      def SPI_IOC_WR_MODE32;          _IOW(SPI_IOC_MAGIC, 5, 4); end

      # If n * sizeof(spi_ioc_transfer) > 1 << _IOC_SIZEBITS we should return 0 instead
      # In other words, I think the limit is the number of 32byte array we can fit in a 14 bit number
      # See the relevant #define
      def SPI_IOC_MESSAGE(n);         _IOW(SPI_IOC_MAGIC, 0, n*32); end
    end
  end
end


__END__
  class SPIException < Exception ; end
  class SPINoDevice < SPIException ; end


NB: Before 3.15 __u32 and tx_nbits/rx_nbits didn't exist. Some distros seem to have the old header even on newer kernels



