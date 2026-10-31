# 在野火 HPM6750 开发板上运行 Zephyr

这个项目为野火 HPM6750 BTB 核心板/底板补充 Zephyr 板级支持。目标是让这块开发板可以像 Zephyr 官方开发板一样，通过统一命令完成编译、烧录和调试。

如果你以前没有接触过 Zephyr，可以先记住三个名词：

- **Zephyr**：面向单片机的实时操作系统。
- **板级支持**：告诉 Zephyr 这块板使用什么芯片，以及 LED、串口、Flash 和 SDRAM 接到了哪些引脚。
- **west**：Zephyr 的项目管理命令，用来下载源码、编译和烧录程序。

本项目使用 Zephyr 3.7 LTS、HPMicro `zephyr_sdk_glue` 和 HPM SDK 1.11.0。依赖版本已经锁定，不需要自行选择版本。

## 目前能做什么

| 功能 | 状态 | 说明 |
| --- | --- | --- |
| 工程编译 | 已通过 | 可以生成 ELF、BIN 和 HEX 固件 |
| 串口 | 已适配 | UART0，PY06 发送、PY07 接收，115200 8N1 |
| LED | 已适配 | LED4/5/6，依次闪烁 |
| NOR Flash | 已适配 | 板载 W25Q256，容量 32 MiB |
| SDRAM | 已适配 | 板载 W9825G6KH-6，容量 32 MiB，16-bit 总线 |
| 实板运行 | 等待验证 | 还需要在真实开发板上验证烧录、串口和 LED |
| Ethernet、USB、SD、LCD、CAN | 尚未适配 | 后续逐项增加 |

## 开始前需要准备

硬件：

- 野火 HPM6750 BTB 核心板和配套底板
- 可工作的 USB 数据线
- 调试器；使用野火 DAP 时，需要将其配置为 CMSIS-DAP 模式
- 一个 3.3 V USB 转串口模块，用于查看 UART0 输出

电脑上需要安装：

- Git
- Python 3.8 或更高版本
- CMake 3.20 或更高版本
- Ninja
- Zephyr SDK 0.16.5 或更高版本

安装完成后，在终端执行下面的命令安装 `west`：

```bash
python -m pip install --user west
```

用下面的命令检查工具是否可用：

```bash
git --version
python --version
cmake --version
ninja --version
west --version
```

每条命令都能显示版本号，才继续下一步。如果提示找不到 `west`，请关闭终端后重新打开；仍然找不到时，需要把 Python 的用户脚本目录加入 `PATH`。

## 第一步：下载完整工程

选择一个用于存放工程的目录，在该目录打开终端，然后执行：

```bash
west init -m https://github.com/sendu2wfdx/zephyr-embedfire-hpm6750.git hpm6750-zephyr
cd hpm6750-zephyr
west update
west supply
```

这些命令会创建 `hpm6750-zephyr` 工作区，并下载 Zephyr、HPM SDK 和本项目。首次下载文件较多，耗时取决于网络速度。不要只单独下载本仓库的 ZIP 文件，因为编译时还需要工作区内的其他依赖。

下载完成后的主要目录如下：

```text
hpm6750-zephyr/
├── zephyr/                         Zephyr 源码
├── sdk_glue/                       HPMicro 的 Zephyr 适配层
├── sdk_env/                        HPM SDK
└── zephyr-embedfire-hpm6750/       本项目
```

## 第二步：编译示例程序

确认终端当前位于 `hpm6750-zephyr` 目录，然后执行：

```bash
west build -p always -b hpm6750_embedfire_btb zephyr-embedfire-hpm6750
```

这里的 `hpm6750_embedfire_btb` 是本项目为野火开发板定义的板卡名称。第一次编译会做完整配置，后续修改程序后可以把 `-p always` 去掉以缩短编译时间。

看到类似下面的信息表示编译成功：

```text
[156/156] Linking C executable zephyr/zephyr.elf
```

生成的固件位于 `build/zephyr/`：

- `zephyr.elf`：包含调试信息，适合调试器使用
- `zephyr.bin`：纯二进制固件
- `zephyr.hex`：Intel HEX 格式固件

## 第三步：连接开发板

1. 将调试器连接到开发板，并确认电脑能够识别 CMSIS-DAP 设备。
2. 将 USB 转串口模块的 RX 接到开发板 UART0 TX（PY06）。
3. 将两块板的 GND 相连。
4. 串口工具设置为 `115200` 波特率、8 数据位、无校验、1 停止位。

不要把 USB 转串口模块的 5 V 电平直接接到开发板 IO。开发板串口使用 3.3 V 电平。

## 第四步：烧录和观察结果

在完成编译的同一个终端中执行：

```bash
west flash
```

当前烧录配置复用了 HPMicro HPM6750EVK2 的 SoC 级 OpenOCD 脚本，因为两块板都从 XPI0 NOR Flash 启动。这个流程还没有在野火实板上完成最终验证，首次操作前请备份原有固件，不要在没有备份的情况下整片擦除 Flash。

程序正常运行后，串口会输出：

```text
EmbedFire HPM6750 Zephyr smoke test
```

随后 LED4、LED5、LED6 会依次闪烁。能同时看到串口文字和 LED 闪烁，就说明最小板级适配运行成功。

## 修改示例程序

示例程序位于：

```text
zephyr-embedfire-hpm6750/app/src/main.c
```

修改后，在工作区根目录重新执行：

```bash
west build
west flash
```

板卡配置、引脚和存储器定义位于：

```text
zephyr-embedfire-hpm6750/boards/hpmicro/hpm6750_embedfire_btb/
```

## 遇到问题时先检查

- `west init` 或 `west update` 失败：检查网络以及 Git 是否能正常访问 GitHub。
- 找不到 `west`：重新打开终端，检查 Python 用户脚本目录是否已经加入 `PATH`。
- 提示找不到工具链：检查 Zephyr SDK 是否安装，以及 `ZEPHYR_SDK_INSTALL_DIR` 是否指向正确目录。
- 找不到板卡：确认编译命令是在 `hpm6750-zephyr` 工作区中执行，并且 `west update` 已经完成。
- 无法烧录：确认调试器工作在 CMSIS-DAP 模式，并检查 SWD/JTAG 接线和开发板供电。
- 串口没有输出：检查是否连接到 PY06、两端是否共地，以及波特率是否为 115200。

如果问题仍然存在，请在 GitHub Issues 中附上完整命令、完整错误日志、操作系统版本和调试器型号。只截取最后一行错误通常不足以定位问题。

## 硬件信息来源

板级参数来自野火原理图、器件规格书和同一硬件的已有 BSP：

- W25Q256JVEIQ，XPI0 NOR Flash，32 MiB
- W9825G6KH-6，16-bit SDR SDRAM，32 MiB
- UART0：PY06/PY07
- LED4/5/6：PB29/PB30/PB31，低电平点亮

## 许可证

Apache-2.0
