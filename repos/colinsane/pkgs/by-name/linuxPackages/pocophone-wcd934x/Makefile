obj-m := snd-soc-wcd934x.o
snd-soc-wcd934x-y := wcd934x.o

all:
	$(MAKE) -C "$(KERNEL_DIR)" M="$(PWD)" modules
install:
	install -Dm444 snd-soc-wcd934x.ko $(INSTALL_MOD_PATH)/sound/soc/codecs/snd-soc-wcd934x.ko
