// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `tlgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"aon_timer", '{
        '{32'h40000000, 32'h40000fff}
    }},
    '{"rv_timer", '{
        '{32'h40001000, 32'h40001fff}
    }},
    '{"gpio", '{
        '{32'h40002000, 32'h40002fff}
    }},
    '{"i2c0", '{
        '{32'h40100000, 32'h40100fff}
    }},
    '{"i2c1", '{
        '{32'h40101000, 32'h40101fff}
    }},
    '{"pattgen", '{
        '{32'h40500000, 32'h40500fff}
    }},
    '{"pwm", '{
        '{32'h40600000, 32'h40600fff}
    }},
    '{"spi_host0", '{
        '{32'h40200000, 32'h40200fff}
    }},
    '{"spi_host1", '{
        '{32'h40201000, 32'h40201fff}
    }},
    '{"uart0", '{
        '{32'h40300000, 32'h40300fff}
    }},
    '{"uart1", '{
        '{32'h40301000, 32'h40301fff}
    }},
    '{"usbdev", '{
        '{32'h40400000, 32'h40400fff}
}}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"main", 0, '{
        "rv_timer",
        "aon_timer",
        "gpio",
        "i2c0",
        "i2c1",
        "pattgen",
        "pwm",
        "spi_host0",
        "spi_host1",
        "uart0",
        "uart1",
        "usbdev"}}
};
