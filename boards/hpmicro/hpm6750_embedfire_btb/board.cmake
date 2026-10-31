# SPDX-License-Identifier: Apache-2.0

set(OPENOCD_CONFIG_RELATIVE ${ZEPHYR_BASE}/../sdk_env/hpm_sdk/boards/openocd)
set(HPM_TOOLS_RELATIVE ${ZEPHYR_BASE}/../sdk_env/tools)
get_filename_component(OPENOCD_CONFIG_ABSOLUTE ${OPENOCD_CONFIG_RELATIVE} ABSOLUTE)
get_filename_component(HPM_TOOLS_ABSOLUTE ${HPM_TOOLS_RELATIVE} ABSOLUTE)
set(OPENOCD_CONFIG_DIR ${OPENOCD_CONFIG_ABSOLUTE} CACHE PATH "HPMicro OpenOCD config root")
set(HPM_TOOLS_DIR ${HPM_TOOLS_ABSOLUTE} CACHE PATH "HPMicro tools root")

if(NOT CONFIG_XIP)
  board_runner_args(openocd "--use-elf")
endif()

# The SoC-level probe setup is shared with HPM6750EVK2. The flash is on XPI0.
board_runner_args(openocd "--config=${OPENOCD_CONFIG_DIR}/probes/cmsis_dap.cfg"
                            "--config=${OPENOCD_CONFIG_DIR}/soc/hpm6750-single-core.cfg"
                            "--config=${OPENOCD_CONFIG_DIR}/boards/hpm6750evk2.cfg"
                            "--openocd-search=${OPENOCD_CONFIG_DIR}")
board_runner_args(openocd --target-handle=_CHIPNAME.cpu0)

set(ENV_PATH $ENV{PATH})
unset(OPENOCD CACHE)
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
  string(REPLACE ":" ";" ZPATH ${ENV_PATH})
  find_program(OPENOCD openocd PATHS ${ZPATH} NO_DEFAULT_PATH)
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
  set(OPENOCD "${HPM_TOOLS_DIR}/openocd/openocd.exe" CACHE FILEPATH "" FORCE)
  set(OPENOCD_DEFAULT_PATH ${HPM_TOOLS_DIR}/openocd/tcl)
else()
  message(WARNING "${CMAKE_HOST_SYSTEM_NAME} OpenOCD is not supported")
endif()

include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)

