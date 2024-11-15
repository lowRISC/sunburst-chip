#pragma once
#include <stdint.h>

#define PWM_NUM_OUTPUTS 6u

struct OpenTitanPwm
{
  uint32_t alert_test;
  uint32_t regwen;
  uint32_t cfg;
  uint32_t pwm_en;
  uint32_t invert;
  uint32_t pwm_param[PWM_NUM_OUTPUTS];
  uint32_t duty_cycle[PWM_NUM_OUTPUTS];
  uint32_t blink_param[PWM_NUM_OUTPUTS];
};
