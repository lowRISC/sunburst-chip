#pragma once
#include <stdint.h>

struct OpenTitanPattgen
{
  uint32_t intr_state;
  uint32_t intr_enable;
  uint32_t intr_test;
  uint32_t alert_test;
  uint32_t ctrl;
  uint32_t prediv_ch0;
  uint32_t prediv_ch1;
  uint32_t data_ch0_0;
  uint32_t data_ch0_1;
  uint32_t data_ch1_0;
  uint32_t data_ch1_1;
  uint32_t size;
};
