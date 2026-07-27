# vdemeester's ergodox layout

This is an unconventional layour for the [ErgoDox EZ][ez], based on
the bepo one from [jackhumbert/qmk_firmware][qmk_firmware].

## Building

This layout is maintained in its own repository. To build it, you will
need the [QMK][qmk_firmware] firmware checked out, and this repository
checked out to something like `keyboards/ergodox_ez/keymaps/sbr`.

```bash
$ git clone https://github.com/jackhumbert/qmk_firmware.git
$ cd qmk_firmware
$ git clone https://github.com/vdemeester/ergodox.git \
            keyboards/ergodox-ez/keymaps/sbr
$ make ergodox-ez:sbr
```

Then you can load it into the [Ergodox EZ][ez].

```bash
$ sudo teensy-loader-cli -mmcu=atmega32u4 -w ergodox_ez_sbr.hex -v
```

[qmk_firmware]: https://github.com/jackhumbert/qmk_firmware
[ez]: https://ergodox-ez.com/
