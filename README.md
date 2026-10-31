# Zephyr for EmbedFire HPM6750 BTB

野火 HPM6750 BTB 核心板/底板的 Zephyr 板级适配。当前是可验证的最小端口，基于 HPMicro `zephyr_sdk_glue` 和 Zephyr 3.7 LTS。

## 当前状态

- [x] HPM6750 SoC 与 XPI0 XIP 配置
- [x] W25Q256 32 MiB NOR Flash 容量与分区
- [x] UART0：PY06 TX / PY07 RX，115200 8N1
- [x] LED4/LED5/LED6：PB29/PB30/PB31，低电平点亮
- [x] W9825G6KH-6 32 MiB SDRAM（16-bit，PC/PD 物理走线）
- [ ] 实板 Zephyr 串口/闪灯验证
- [ ] Ethernet / USB / SD / LCD / CAN

PB29/PB30/PB31 具有 FEMC 复用功能，但野火这块板的 16-bit SDRAM 物理数据线走 PC/PD 组，PB29/PB30/PB31 物理连接 LED4/5/6。本端口只初始化实际走线的 FEMC 引脚，因此 SDRAM 与三颗 LED 可以同时使用。

## 初始化工作区

```bash
west init -m https://github.com/OWNER/zephyr-embedfire-hpm6750.git hpm6750-zephyr
cd hpm6750-zephyr
west update
west supply
```

`west.yml` 锁定 HPMicro glue 提交 `1756cb8f`，该 glue 再锁定 Zephyr 3.7.0 和 HPM SDK 1.11.0。

## 编译

```bash
west build -p always -b hpm6750_embedfire_btb zephyr-embedfire-hpm6750
```

产物位于 `build/zephyr/`。冒烟程序会在 UART0 输出：

```text
EmbedFire HPM6750 Zephyr smoke test
```

然后 LED4、LED5、LED6 依次闪烁。

## 烧录

```bash
west flash
```

当前 runner 复用 HPMicro HPM6750EVK2 的 SoC 级 OpenOCD 脚本，因为两者都从 XPI0 NOR 启动。如使用野火 DAP，请确保它以 CMSIS-DAP 模式枚举。第一次实板烧录前建议保留原有可启动镜像。

## Linux

- 在 Linux 主机上编译/烧录 Zephyr：可行。
- 在 HPM6750 上运行常规 Linux：不建议，该 MCU 没有常规 Linux 所需的页式 MMU。
- NOMMU/uClinux：理论可研究，但需要独立的内核/BSP 移植，不是本仓库的短期目标。

详见 [docs/linux.md](docs/linux.md)。

## 硬件依据

板级参数来自野火原理图/规格书与已在同一工作区实板验证的 RT-Thread BSP：

- W25Q256JVEIQ，XPI0，32 MiB
- W9825G6KH-6，16-bit SDR SDRAM，32 MiB
- UART0：PY06/PY07
- LED4/5/6：PB29/PB30/PB31，active-low

## License

Apache-2.0

