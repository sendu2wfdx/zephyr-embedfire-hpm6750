# SPDX-License-Identifier: Apache-2.0

# Compatibility for two defects in sdk_glue 1756cb8 when used with the
# HPM SDK revision imported by that same manifest. Keep the workarounds here
# so applications using this board do not have to patch their dependencies.
if(CONFIG_ETH_HPM_RMII)
  zephyr_compile_definitions(media_interface=rmii_refclk_dir)
endif()

if(CONFIG_ADC)
  zephyr_compile_options(
    $<$<COMPILE_LANGUAGE:C>:-include${CMAKE_CURRENT_LIST_DIR}/hpm_adc_compat.h>
  )
endif()

if(CONFIG_EBF_HPM6750_PWM1_HEADER AND CONFIG_EBF_HPM6750_SPI2_HEADER)
  message(FATAL_ERROR
    "HPM6750 pin conflict: PWM1 CH2..CH5 and SPI2 share PB21/PB22/PB24/PB25")
endif()

if(CONFIG_EBF_HPM6750_PWM1_HEADER AND CONFIG_EBF_HPM6750_CAN1_PB_HEADER)
  message(FATAL_ERROR
    "HPM6750 pin conflict: PWM1 CH0/CH1 and CAN1 PB route share PB19/PB18")
endif()

if(CONFIG_EBF_HPM6750_CAN2_ONBOARD AND CONFIG_EBF_HPM6750_CAN2_HEADER)
  message(FATAL_ERROR
    "HPM6750 route conflict: CAN2 cannot use onboard PD20/PD25 and header PY10/PY11 together")
endif()
