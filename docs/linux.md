# Linux 可行性

## 结论

HPM6750 适合运行 Zephyr、RT-Thread、NuttX 这类 RTOS，不适合作为常规 Linux 主机。

HPM6750 是 32 位 RISC-V MCU，有 S-mode 和 PMP，但没有常规 Linux 所需的页式 MMU。野火核心板上的 32 MiB SDRAM 从容量上可以尝试极小的 NOMMU/uClinux 系统，但这需要新增启动链、中断、时钟、串口、Flash、SDRAM 和设备树等平台支持，且没有进程地址空间隔离。这是一个独立的研发项目，不是本 Zephyr 端口的简单开关。

## 实用选择

1. 需要实时、网络、USB、文件系统和 GUI：优先 Zephyr 或 NuttX。
2. 需要 systemd、容器、完整 POSIX 用户空间或丰富软件包：换用带 MMU 的 MPU，例如 i.MX6ULL、STM32MP1 或 RK3568。
3. 只想在 Linux 电脑上开发 HPM6750：完全可行，HPMicro Zephyr glue 支持 Linux 主机上的 CMake/Ninja/West 工作流。

