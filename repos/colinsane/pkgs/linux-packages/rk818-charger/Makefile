obj-m := rk818_battery.o rk818_charger.o rk8xx-core.o rk8xx-i2c.o

all:
	$(MAKE) -C "$(KERNEL_DIR)" M="$(PWD)" modules
install:
	install -Dm444 rk818_battery.ko $(INSTALL_MOD_PATH)/drivers/power/supply/rk818_battery.ko
	install -Dm444 rk818_charger.ko $(INSTALL_MOD_PATH)/drivers/power/supply/rk818_charger.ko
	install -Dm444 rk8xx-core.ko $(INSTALL_MOD_PATH)/drivers/mfd/rk8xx-core.ko
	install -Dm444 rk8xx-i2c.ko $(INSTALL_MOD_PATH)/drivers/mfd/rk8xx-i2c.ko
