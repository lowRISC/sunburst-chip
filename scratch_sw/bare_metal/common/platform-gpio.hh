#pragma once

struct OpenTitanGPIO
{
  uint32_t intr_state;
  uint32_t intr_enable;
  uint32_t intr_test;
  uint32_t alert_test;
  uint32_t data_in;
  uint32_t direct_out;
  uint32_t masked_out_lower;
  uint32_t masked_out_upper;
  uint32_t direct_oe;
  uint32_t masked_oe_lower;
  uint32_t masked_oe_upper;
  uint32_t intr_ctrl_en_rising;
  uint32_t intr_ctrl_en_falling;
  uint32_t intr_ctrl_en_lvlhigh;
  uint32_t intr_ctrl_en_lvllow;
  uint32_t ctrl_en_input_filter;

  void set_out_direct(uint32_t out) volatile
  {
    direct_out = out;
  }

  void set_oe_direct(uint32_t oe) volatile
  {
    direct_oe = oe;
  }
};
