
obj-m := unkillable.o

all:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

unkillable.o:
	# why does the name of the c source file seemingly need to match the .o file
	# i'd like to have kernel_module.c
	$(CC) unkillable.c -o unkillable.o

install:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules_install
