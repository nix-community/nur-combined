obj-m := snd-soc-rt5640.o

all:
	$(MAKE) -C "$(KERNEL_DIR)" M="$(PWD)" modules
install:
	install -Dm444 snd-soc-rt5640.ko $(INSTALL_MOD_PATH)/sound/soc/codecs/snd-soc-rt5640.ko

