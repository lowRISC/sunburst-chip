/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

struct SunburstPattgen
{
	uint32_t interruptState;
	uint32_t interruptEnable;
	uint32_t interruptTest;

  // ... other registers ...

  // Sunburst PattgenInterrupts
	typedef enum [[clang::flag_enum]] : uint32_t
	{
		/// Raised whenever channel 1 completes pattern output.
		InterruptDoneCh1 = 1 << 1,
		/// Raised whenever channel 0 completes pattern output.
		InterruptDoneCh0 = 1 << 0,
	} SunburstPattgenInterrupt;

	/// Enable the given interrupt(s).
	void interrupt_enable(SunburstPattgenInterrupt interrupt) volatile
	{
		interruptEnable = interruptEnable | interrupt;
	}

	/// Disable the given interrupt(s).
	void interrupt_disable(SunburstPattgenInterrupt interrupt) volatile
	{
		interruptEnable = interruptEnable & ~interrupt;
	}
};
