{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  imports = [
    ./win10
  ];

  system.activationScripts.libvirt-hooks.text =
    ''
      ln -Tfs /etc/libvirt/hooks /var/lib/libvirt/hooks
    '';
  environment.etc."libvirt/hooks/qemu" = {
    text =
      ''
        #!${pkgs.bash}/bin/bash
        GUEST_NAME="''$1"
        HOOK_NAME="''$2"
        STATE_NAME="''$3"
        MISC="''${@:4}"

        BASEDIR="''$(dirname ''$0)"

        HOOKPATH="''$BASEDIR/qemu.d/''$GUEST_NAME/''$HOOK_NAME/''$STATE_NAME"

        set -e # If a script exits with an error, we should as well.

        # check if it's a non-empty executable file
        if [ -f "''$HOOKPATH" ] && [ -s "''$HOOKPATH"] && [ -x "''$HOOKPATH" ]; then
        eval \"''$HOOKPATH\" "$@"
        elif [ -d "''$HOOKPATH" ]; then
        while read file; do
        # check for null string
        if [ ! -z "''$file" ]; then
        eval \"''$file\" "''$@"
        fi
        done <<< "''$(find -L "''$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
        fi
      '';
    mode = "0755";
  };


  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.ovmf.enable = true;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.runAsRoot = true;
    qemu.swtpm.enable = true;
    qemu.package = pkgs.qemu_full;
  };

  environment.systemPackages = with pkgs; [
    virtiofsd
    config.virtualisation.libvirtd.qemu.package
    looking-glass-client
    virt-manager
    libguestfs-with-appliance
  ];

  systemd.services.libvirtd = {
    path =
      let
        env = pkgs.buildEnv {
          name = "qemu-hook-env";
          paths = with pkgs; [
            bash
            libvirt
            kmod
            systemd
            ripgrep
            sd
            coreutils
            sudo
            su
            killall
            procps
            util-linux
            bindfs
            qemu-utils
          ];
        };
      in
      [ env ];
  };
}
