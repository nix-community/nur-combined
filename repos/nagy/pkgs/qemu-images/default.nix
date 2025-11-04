{
  pkgs,
  lib ? pkgs.lib,
  fetchurl,
  fetchFromGitHub,
  qemu,
  recurseIntoAttrs,
}:

# more info here
# https://raspberrypi.stackexchange.com/questions/89196/emulate-raspberry-pi-zero-w-with-qemu-failed-due-to-missing-dtb

# * TODO rasp qemu
# https://azeria-labs.com/emulate-raspberry-pi-with-qemu/
# https://github.com/dhruvvyas90/qemu-rpi-kernel
# https://gitlab.com/qemu-project/qemu/-/issues/448
# https://www.qemu.org/docs/master/system/arm/raspi.html?highlight=raspi0

let
  selflib = (import ../.. { inherit pkgs; }).lib;
  qemu-rpi-kernel = fetchFromGitHub {
    owner = "dhruvvyas90";
    repo = "qemu-rpi-kernel";
    rev = "9fb4fcf463df4341dbb7396df127374214b90841";
    hash = "sha256-fgqiWLT8zNTHEQ7Ky+Gf6X0hBFQ0ira4bh7szQrEV48=";
  };
  makeExpectScript =
    image:
    (selflib.writeExpectBin "raspberrypi-interact" ''
      set timeout -1

      set IMAGE image.qcow2
      catch {set IMAGE $::env(QEMU_IMAGE)}
      set USER pi
      catch {set USER $::env(QEMU_USER)}
      set PASSWORD raspberry
      catch {set PASSWORD $::env(QEMU_PASSWORD)}

      system ${qemu}/bin/qemu-img create -f qcow2 -F qcow2 -b ${image} $IMAGE

      spawn ${qemu}/bin/qemu-system-arm  \
                 -kernel ${qemu-rpi-kernel}/kernel-qemu-5.10.63-bullseye \
                 -cpu arm1176 \
                 -m 256 \
                 -M versatilepb \
                 -dtb ${qemu-rpi-kernel}/versatile-pb-bullseye-5.10.63.dtb \
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
    '').overrideAttrs
      (
        finalAttrs: previousAttrs: {
          passthru.interact =
            pkgs.runCommandLocal finalAttrs.name
              {
                oldBinary = lib.getExe finalAttrs.finalPackage;
                nativeBuildInputs = [ pkgs.makeWrapper ];
              }
              ''
                mkdir -p $out/bin
                makeWrapper $oldBinary $out/bin/${finalAttrs.name} \
                  --set QEMU_INTERACT 1
              '';
        }
      );
in
{
  raspberryPi = recurseIntoAttrs rec {

    buster-lite = fetchurl {
      pname = "raspios-buster-armhf-lite";
      version = "2022-09-06";
      url = "https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-09-07/2022-09-06-raspios-buster-armhf-lite.img.xz";
      # From https://www.raspberrypi.com/software/operating-systems/
      # https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-09-07/2022-09-06-raspios-buster-armhf-lite.img.xz.sha256
      sha256 = "9a38607cee9ca6844ee26c1e12fb9d029b567c8235e8b9f78f382a19e6078720";
    };
    buster-lite-qcow2 = selflib.makeCompressedQcow2 { image = buster-lite; };
    buster-lite-script = makeExpectScript buster-lite-qcow2;
    buster-lite-newimage = pkgs.runCommandLocal "newimage.qcow2" {
      env = {
        QEMU_USER = "pi";
        QEMU_PASSWORD = "raspberry";
        QEMU_IMAGE = placeholder "out";
      };
    } (lib.getExe buster-lite-script);
  };
}
