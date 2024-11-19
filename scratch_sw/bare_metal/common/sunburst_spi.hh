/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

struct SunburstSpi
{
	uint32_t interruptState;
	uint32_t interruptEnable;
	uint32_t interruptTest;

  // ... other registers ...

	/// Sunburst SPI Interrupts
	typedef enum [[clang::flag_enum]] : uint32_t
	{
		/// Asserted whilst one or more SPI events requires attention.
		InterruptSpiEvent = 1 << 1,
		/// Raised whenever an error occurs.
		InterruptError = 1 << 0,
	} SunburstSpiInterrupt;

	/// Enable the given interrupt(s).
	void interrupt_enable(SunburstSpiInterrupt interrupt) volatile
	{
		interruptEnable = interruptEnable | interrupt;
	}

	/// Disable the given interrupt(s).
	void interrupt_disable(SunburstSpiInterrupt interrupt) volatile
	{
		interruptEnable = interruptEnable & ~interrupt;
	}
};
