# A small Windows VM for running native Windows builds (nova-nix, MSYS2).
#
# Adapted from NixOS/nixpkgs#492435: boots the Validation OS image from
# Microsoft's evaluation site, which is a WinPE-like Windows with SSH and
# without the desktop.  The image is patched to start sshd, turn off the
# firewall and authorise the test key below; `runWithWindowsSsh` boots a fresh
# copy, waits for SSH and runs a command, then kills QEMU.
#
# Notes from using it with nova-nix:
#  - Boot with the IDE disk (`-hda`) and KVM; a virtio disk does not boot.
#  - The guest has no CA store, so HTTPS fails.  Mirror binary caches over
#    plain HTTP, or import a CA bundle manually.
#  - The guest also lacks tar, PowerShell and certutil; `scp -r` works.
#
#   nix build .#legacyPackages.x86_64-linux.validationos-vm.validationVhdx
#
# `runWithWindowsSsh` is a function, so build a call with --expr:
#   nix build --impure --expr \
#     '(builtins.getFlake (toString ./.)).legacyPackages.x86_64-linux.validationos-vm.runWithWindowsSsh "windows-version" "$SSH ver > $out"'
{
  lib,
  fetchurl,
  writeText,
  qemu,
  runCommand,
  p7zip,
  libguestfs-with-appliance,
  chntpw,
  netcat,
  openssh,
  OVMF,
  efiFirmware ? OVMF.fd.firmware,
}:

rec {
  validationIso = fetchurl {
    url = "https://software-static.download.prss.microsoft.com/dbazure/998969d5-f34g-4e03-ac9d-1f9786c66749/26100.7019.251023-1855.ge_release_svc_prod3_amd64fre_en-us_VALIDATIONOS.iso";
    hash = "sha256-gHWQkjXi4ALAtB8q7F8b8hFoQ1lZThrFq9ivD3m/oGc=";
    meta.license = lib.licenses.unfree;
  };

  startupScript =
    commands:
    writeText "startnet.valos.cmd" ''
      @ECHO OFF
      IF NOT DEFINED StartupRun (
        ${commands}
        SET StartupRun=1
      )
    '';

  makeValidationVhdx =
    startupCommands:
    runCommand "ValidationOS.vhdx"
      {
        nativeBuildInputs = [
          p7zip
          libguestfs-with-appliance
          chntpw
        ];
        meta.license = lib.licenses.unfree;
      }
      ''
        7z x ${validationIso} ValidationOS.vhdx
        mv ValidationOS.vhdx $out

        export HOME=$(mktemp -d)
        guestfish -a $out -m /dev/sda4 upload ${startupScript startupCommands} /Windows/System32/startnet.valos.cmd
        guestfish -a $out -m /dev/sda4 download /Windows/System32/config/SOFTWARE SOFTWARE
        echo "y" | reged -I SOFTWARE "HKEY_LOCAL_MACHINE\SOFTWARE" ${./Winlogon.reg} || true # reged exits 2 for successful writes!
        guestfish -a $out -m /dev/sda4 upload SOFTWARE /Windows/System32/config/SOFTWARE
      '';

  validationVhdx = makeValidationVhdx ''
    netsh.exe advfirewall set allprofiles state off
    echo ${lib.trim (builtins.readFile ./test-windows-key.pub)} > C:\ProgramData\ssh\administrators_authorized_keys
  '';

  qemuCommandWindows = ''
    ${qemu}/bin/qemu-system-x86_64 \
      -accel kvm -cpu host \
      -m 4096 -smp 4 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -device e1000e,netdev=net0 \
      -drive if=pflash,format=raw,unit=0,readonly=on,file=${efiFirmware} \
      ''${diskImage:+-hda $diskImage} \
      $QEMU_OPTS
  '';

  runWithWindowsSsh =
    name: command:
    runCommand name
      {
        SSH_USERNAME = "Administrator";
        SSH_PORT = 2222;
        MAX_WAIT = 60;
        QEMU_OPTS = [ "-nographic" ];

        requiredSystemFeatures = [ "kvm" ];
        nativeBuildInputs = [
          qemu
          netcat
          openssh
        ];
        buildInputs = [ OVMF.fd ];
      }
      ''
        cp "${validationVhdx}" ValidationOS.vhdx
        chmod u+w ValidationOS.vhdx

        export diskImage=$PWD/ValidationOS.vhdx
        set -x
        ${lib.trim qemuCommandWindows} &
        set +x
        QEMU_PID=$!

        SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${./test-windows-key}"
        SSH="ssh $SSH_ARGS -p $SSH_PORT $SSH_USERNAME@127.0.0.1"

        echo "Waiting for SSH..."
        for i in $(seq 1 "$MAX_WAIT"); do
          if $SSH -o ConnectTimeout=1 -n >/dev/null 2>&1; then
            echo "SSH is up"
            break
          fi
          sleep 1
        done

        if [ "$i" -eq "$MAX_WAIT" ]; then
          echo "SSH never came up" >&2
          exit 1
        fi

        ${command}

        kill $QEMU_PID || true
      '';

  version = runWithWindowsSsh "windows-version" ''
    $SSH "ver" > $out
  '';
}
