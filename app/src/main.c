/* SPDX-License-Identifier: Apache-2.0 */

#include <zephyr/device.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#define LED0_NODE DT_ALIAS(led0)
#define LED1_NODE DT_ALIAS(led1)
#define LED2_NODE DT_ALIAS(led2)

static const struct gpio_dt_spec leds[] = {
	GPIO_DT_SPEC_GET(LED0_NODE, gpios),
	GPIO_DT_SPEC_GET(LED1_NODE, gpios),
	GPIO_DT_SPEC_GET(LED2_NODE, gpios),
};

int main(void)
{
	printk("EmbedFire HPM6750 Zephyr smoke test\n");

	for (size_t i = 0; i < ARRAY_SIZE(leds); ++i) {
		if (!gpio_is_ready_dt(&leds[i])) {
			printk("LED%u GPIO is not ready\n", (unsigned)i);
			return 0;
		}

		if (gpio_pin_configure_dt(&leds[i], GPIO_OUTPUT_INACTIVE) != 0) {
			printk("LED%u GPIO configuration failed\n", (unsigned)i);
			return 0;
		}
	}

	for (;;) {
		for (size_t i = 0; i < ARRAY_SIZE(leds); ++i) {
			gpio_pin_toggle_dt(&leds[i]);
			k_sleep(K_MSEC(500));
			gpio_pin_toggle_dt(&leds[i]);
		}
	}
}

