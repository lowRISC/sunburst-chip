echo Generating register definitions for top chip
GEN_REGS="hw/vendor/lowrisc_ip/util/regtool.py -D -o"
echo Generating register definitions for aon_timer IP block
$GEN_REGS sw/device/regs/aon_timer_regs.h hw/vendor/lowrisc_ip/ip/aon_timer/data/aon_timer.hjson
echo Generating register definitions for gpio IP block
$GEN_REGS sw/device/regs/gpio_regs.h hw/vendor/lowrisc_ip/ip/gpio/data/gpio.hjson
echo Generating register definitions for i2c IP block
$GEN_REGS sw/device/regs/i2c_regs.h hw/vendor/lowrisc_ip/ip/i2c/data/i2c.hjson
echo Generating register definitions for pattgen IP block
$GEN_REGS sw/device/regs/pattgen_regs.h hw/vendor/lowrisc_ip/ip/pattgen/data/pattgen.hjson
echo Generating register definitions for pwm IP block
$GEN_REGS sw/device/regs/pwm_regs.h hw/vendor/lowrisc_ip/ip/pwm/data/pwm.hjson
echo Generating register definitions for rv_plic IP block
$GEN_REGS sw/device/regs/rv_plic_regs.h hw/top_chip/ip_autogen/rv_plic/data/rv_plic.hjson
echo Generating register definitions for rv_timer IP block
$GEN_REGS sw/device/regs/rv_timer_regs.h hw/vendor/lowrisc_ip/ip/rv_timer/data/rv_timer.hjson
echo Generating register definitions for spi_host IP block
$GEN_REGS sw/device/regs/spi_host_regs.h hw/vendor/lowrisc_ip/ip/spi_host/data/spi_host.hjson
echo Generating register definitions for uart IP block
$GEN_REGS sw/device/regs/uart_regs.h hw/vendor/lowrisc_ip/ip/uart/data/uart.hjson
echo Generating register definitions for usbdev IP block
$GEN_REGS sw/device/regs/usbdev_regs.h hw/vendor/lowrisc_ip/ip/usbdev/data/usbdev.hjson
