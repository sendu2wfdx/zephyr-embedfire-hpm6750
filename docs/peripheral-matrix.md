# 外设与引脚复用表

本文件记录野火 HPM6750 BTB 底板的实际接线、Zephyr 接入程度和已知冲突。项目采用“默认安全关闭、snippet 按需开启”的方式；设备树中出现一个节点，并不自动表示对应驱动已经可用。

状态含义：

- **基础启用**：默认固件会启用。
- **独立构建通过**：相应 snippet 已完成一次完整链接构建，尚待实板验证。
- **只完成接线核对**：HPMicro 的 Zephyr 适配层还没有相应驱动。

## 板载外设

| 功能 | 主要线路 | Zephyr 状态 | 选择方式或说明 |
| --- | --- | --- | --- |
| UART0 | PY06 TX、PY07 RX | 基础启用 | 控制台，115200 8N1 |
| KEY2 / KEY3 | PZ09、PZ11，低有效 | 基础启用 | `sw0`、`sw1`；KEY1 接专用 PBUTN，不冒充 GPIO |
| LED4 / LED5 / LED6 | PB29、PB30、PB31，低有效 | 基础启用 | `led0`～`led2`；LED3 接 SD_CD/PD28 |
| CAN | CAN2：PD20 TX、PD25 RX | 独立构建通过 | `ebf-onboard-can` |
| RS485 | UART1：PB27 TX、PB26 RX；PB20 DE | 独立构建通过 | `ebf-rs485`；DE 由应用通过 `rs485-de-gpios` 控制 |
| RS232-1 | UART7：PC03 TX、PC02 RX | 独立构建通过 | `ebf-rs232` |
| RS232-2 | UART10：PD24 TX、PD23 RX | 独立构建通过 | `ebf-rs232` |
| Ethernet 0 | LAN8720A，PE/PD 组 RMII，PE29 RESET | 独立构建通过 | `ebf-ethernet0` |
| Ethernet 1 | LAN8720A，PE/PD 组 RMII，PE24 RESET | 独立构建通过 | `ebf-ethernet1` |
| SD | SDXC1：PD17/18/21/22/26/27，PD28 CD | 独立构建通过 | `ebf-sdcard`，4-bit、3.3 V |
| USB Type-C | USB1，PF07 ID，DP/DM 专用脚 | 独立构建通过 | `ebf-usb-device`，目前接入设备模式 |
| OV2640 | CAM0 PA00～PA11，I2C3 PB13/PB14，PE05 RESET | 独立构建通过 | `ebf-camera-ov2640` |
| OV5640 | 同一摄像头座，另用 PE00 PWDN | 独立构建通过 | `ebf-camera-ov5640` |
| RGB 屏 | LCDC RGB 数据/同步信号 PA/PB 组，PB23 背光 | 独立构建通过 | `ebf-rgb-display`，当前参数为 800×480 |
| 电容触摸 | I2C0 PB10/PB11，PB08 IRQ，PB09 RESET | 独立构建通过 | 随 `ebf-rgb-display` 启用 GT911 |
| RTC | HPM6750 片内 RTC | 只完成接线核对 | 当前 sdk_glue 没有 HPM RTC 驱动 |
| WM8960 | I2C3 PB13/PB14；I2S0 PF03/PF05/PF06/PF07/PF09 | 只完成接线核对 | 当前 Zephyr 3.7/HPM sdk_glue 缺少可直接使用的 HPM I2S 和 WM8960 驱动 |

## 扩展排针功能

| 功能 | 可用线路 | 状态 |
| --- | --- | --- |
| ADC1 | PE25/CH11、PF00/CH14、PF01/CH15、PF02/CH16、PF04/CH17 | `ebf-adc-header` 独立构建通过 |
| ADC3 | PF10/CH7 | `ebf-adc-header` 独立构建通过 |
| PWM1 | PB19/CH0、PB18/CH1、PB22/CH2、PB21/CH3、PB25/CH4、PB24/CH5 | `ebf-pwm1-header` 独立构建通过 |
| 常用 PWM | PWM0 PB28/CH3、PWM2 PE03/CH3、PWM3 PE06/CH2 | `ebf-pwm-header` 独立构建通过 |
| UART2 | PY08 TX、PY09 RX | `ebf-uart2-header` 独立构建通过 |
| UART11 | PD29 TX、PZ04 RX | `ebf-uart11-header` 独立构建通过 |
| UART12 | PE01 TX、PC20 RX | `ebf-uart12-header` 独立构建通过 |
| UART13 | PE02 TX、PE07 RX | `ebf-uart13-header` 独立构建通过 |
| CAN0 | PB15 TX、PB17 RX | `ebf-can0-header` 独立构建通过；需要外接收发器 |
| CAN1 路由 A | PD16 TX、PD19 RX | `ebf-can1-pd-header` 独立构建通过；需要外接收发器 |
| CAN1 路由 B | PB19 TX、PB18 RX | `ebf-can1-pb-header` 独立构建通过；需要外接收发器 |
| CAN2 扩展路由 | PY10 TX、PY11 RX | `ebf-can2-header` 独立构建通过；会替代板载 CAN2 路由 |
| SPI2 | PB21/PB22/PB25，PB24 CS | `ebf-spi2-header` 独立构建通过 |
| 模拟比较器 | PE21 为 ACMP1 模拟输入 6，另一端可用内部 8-bit DAC 阈值 | sdk_glue 无 ACMP 驱动 |
| DAC | 当前已确认的是 ACMP 内部阈值 DAC；未把它描述成外部模拟输出 | 需先确认底板是否引出独立 DAC 输出，再开发驱动 |
| GPTMR / TIM | 芯片资源存在，可用于计时、捕获、比较 | sdk_glue 尚未提供 Zephyr counter 驱动 |

## 必须处理的冲突

| 资源 | 冲突关系 | 当前处理 |
| --- | --- | --- |
| PF07 | USB1_ID 与 WM8960 的 I2S0_TXD1 共脚 | USB snippet 只负责 USB；未来音频 snippet 必须与它互斥 |
| PB18/PB19 | PWM1 CH1/CH0 与扩展 CAN1 路由 B 共脚 | 同时选择时 CMake 直接报错并停止 |
| PB21/PB22/PB24/PB25 | PWM1 CH3/CH2/CH5/CH4 与扩展 SPI2 共脚 | 同时选择时 CMake 直接报错并停止 |
| CAN2 控制器 | 板载 PD20/PD25 路由与扩展 PY10/PY11 路由不能同时存在 | 同时选择时 CMake 直接报错并停止 |
| 摄像头座 | OV2640 与 OV5640 使用同一组 DVP 和控制线 | 两个 camera snippet 二选一 |
| 双网口 | 两路可同时描述，但网络示例默认只选择一路，便于先验证 PHY 地址、时钟和复位 | 当前提供两个独立 snippet |

## 当前构建结论

基础配置以及板载 CAN、RS485、RS232、Ethernet 0、Ethernet 1、SD、USB device、OV2640、OV5640、RGB+GT911、ADC、PWM0/1/2/3、扩展 UART2/11/12/13、CAN0/1/2 和 SPI2 均完成了独立完整构建。PWM1/SPI2、PWM1/CAN1-PB、板载 CAN2/扩展 CAN2 的冲突组合也完成了反向测试，配置系统会拒绝这些组合。RMII PHY 和 ADC 的通用兼容修复已经移入项目维护的 Glue；SDHC 时钟配置继续由板级代码按照实际时钟树提供。

仍需实板逐项验证：PHY 地址与参考时钟方向、SD 卡插拔极性、USB ID 行为、摄像头复位时序、屏幕精确时序和触摸中断极性。未经实板确认前，不把这些项目标成“硬件验证通过”。
