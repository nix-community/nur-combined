{
  pkgs,
  expect,
  fetchurl,
  fetchFromGitHub,
  recurseIntoAttrs,
  qemu-utils,
  qemu,
  runCommand,
}:

# more info here
# https://raspberrypi.stackexchange.com/questions/89196/emulate-raspberry-pi-zero-w-with-qemu-failed-due-to-missing-dtb

# * TODO rasp qemu
# https://azeria-labs.com/emulate-raspberry-pi-with-qemu/
# https://github.com/dhruvvyas90/qemu-rpi-kernel
# https://gitlab.com/qemu-project/qemu/-/issues/448
# https://www.qemu.org/docs/master/system/arm/raspi.html?highlight=raspi0

recurseIntoAttrs rec {
  lib = {
    qemu-rpi-kernel = fetchFromGitHub {
      owner = "dhruvvyas90";
      repo = "qemu-rpi-kernel";
      rev = "9fb4fcf463df4341dbb7396df127374214b90841";
      sha256 = "sha256-fgqiWLT8zNTHEQ7Ky+Gf6X0hBFQ0ira4bh7szQrEV48=";
    };
    makeCompressedQcow2 =
      img:
      runCommand (pkgs.lib.replaceStrings [ ".img.xz" ] [ ".qcow2" ] img.name)
        {
          nativeBuildInputs = [ qemu-utils ];
        }
        ''
          xzcat ${img} > image
          qemu-img convert -O qcow2 -c -o compression_type=zstd image $out
        '';
    writeExpect = pkgs.writers.makeScriptWriter {
      interpreter = "${expect}/bin/expect -f";
    };
    writeExpectBin = name: lib.writeExpect "/bin/${name}";
    makeExpectScript = image:
      lib.writeExpectBin "qemu-image.exp" ''
        set timeout -1

        set IMAGE image.qcow2
        catch {set IMAGE $::env(QEMU_IMAGE)}
        set USER pi
        catch {set USER $::env(QEMU_USER)}
        set PASSWORD raspberry
        catch {set PASSWORD $::env(QEMU_PASSWORD)}

        system ${qemu}/bin/qemu-img create -f qcow2 -F qcow2 -b ${image} $IMAGE

        spawn ${qemu}/bin/qemu-system-arm  \
                   -kernel ${lib.qemu-rpi-kernel}/kernel-qemu-5.10.63-bullseye \
                   -cpu arm1176 \
                   -m 256 \
                   -M versatilepb \
                   -dtb ${lib.qemu-rpi-kernel}/versatile-pb-bullseye-5.10.63.dtb \
                   -no-reboot \
                   -nographic \
                   -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
                   -drive "file=$IMAGE,index=0,media=disk"

        expect "login: "
        send "$USER\n"

        expect "Password: "
        send "$PASSWORD\n"

        expect "$ "
        send "ls -lah /\n"
        expect "$ "

        if {[info exists ::env(QEMU_INTERACT)]} {
           interact
        } else {
           send "sudo shutdown -h now\n"
           wait
        }
      '';
  };
  raspberryPi = recurseIntoAttrs rec {

    buster-lite = fetchurl {
      pname = "raspios-buster-armhf-lite";
      version = "2022-09-06";
      url = "https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-09-07/2022-09-06-raspios-buster-armhf-lite.img.xz";
      # from https://www.raspberrypi.com/software/operating-systems/
      # https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-09-07/2022-09-06-raspios-buster-armhf-lite.img.xz.sha256
      sha256 = "9a38607cee9ca6844ee26c1e12fb9d029b567c8235e8b9f78f382a19e6078720";
    };
    buster-lite-qcow2 = lib.makeCompressedQcow2 buster-lite;
    buster-lite-script = lib.makeExpectScript buster-lite-qcow2;
    buster-lite-newimage = runCommand "newimage.qcow2" {
      QEMU_USER = "pi";
      QEMU_PASSWORD = "raspberry";
      QEMU_IMAGE = placeholder "out";
    } (pkgs.lib.getExe buster-lite-script);
  };
}
