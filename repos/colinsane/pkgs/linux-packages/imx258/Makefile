obj-m := imx258.o

all:
	$(MAKE) -C "$(KERNEL_DIR)" M="$(PWD)" modules
install:
	install -Dm444 imx258.ko $(INSTALL_MOD_PATH)/drivers/media/i2c/imx258.ko

