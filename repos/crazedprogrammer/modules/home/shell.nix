{ config, pkgs, lib, ... }:

{
  # Use vim for all the things.
  environment.variables = {
    EDITOR = lib.mkOverride 900 "vim";
    TERMINAL = "kitty";
  };

  # Use the fish shell.
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "ls_extended";
      l = "ls -lah";
      vim = "vim -p";
      iotop = "sudo iotop";
      bmon = "sudo bmon";
      potp = "pass otp uuotp | clip";
      cargo = "env LIBRARY_PATH=/run/current-system/sw/lib cargo";
      radonssh = "ssh casper@radon -t tmux";
      ovpn = "sudo openvpn --config ~/.openvpn-(hostname)";
      maps = "nix-shell -p chromium --run \"chromium https://maps.google.com\"";
      lgit = "git add -A; and git commit; and git push";
      lgitf = "git add -A; and git commit; and git pull; and git push";
      qemu = "qemu-system-x86_64 -m 8192 --enable-kvm -cpu host -smp (nproc --all) -vga virtio";
      sysa = "sudo nixos-rebuild switch";
      sysu = "sudo nix-channel --update; sysa";
      sysuf = "cd $HOME/Projects/nixpkgs; git pull upstream master; cd -; sysa -I nixpkgs=$HOME/Projects/nixpkgs";
      sysclean = "sudo nix-collect-garbage -d; and sudo nix-store --optimise";
      nix-shell-unstable = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";

      # TODO: try to find a way to persist the disk image without chown errors during VM boot.
      vm-build = "sudo nixos-rebuild build-vm -p test -I nixos-config=./modules/hosts/nixos-qemu.nix";
      vm-run = "./result/bin/run-nixos-qemu-vm -m 4096 --enable-kvm --smp (nproc --all); and rm ./nixos-qemu.qcow2";

      # Deprecated
      cdcc = "cd ~/.local/share/ccemux/computer/0";
      aubuild = "nix-shell -p automake autoconf libtool --run \"sh autogen.sh\"; and nix-build .";

      esp-shell = "nix-shell (dotfiles)/esp-idf-shell.nix";
      evd-shell = "nix-shell (dotfiles)/evd-shell.nix";
      evd-vm = "qemu $HOME/VMs/debian.qcow2 -fsdev local,security_model=none,id=fsdev0,path=$HOME/Documents/EVD-1/evdk_share -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare";

      ros = "xhost +; docker run $argv --mount source=cargo-cache,target=/home/casper/.cargo/registry --cap-add=SYS_PTRACE -e DISPLAY=$DISPLAY --device /dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/casper/.Xauthority -v $PWD:/pwd --rm -it ros:melodic-custom; echo > /dev/null";
      ros-join = "docker exec -it (docker ps | grep melodic-custom | cut -f 1 -d \" \") tmux";
      ros-install = "docker build -t ros:melodic-custom (dotfiles)/ros-container; and docker volume create cargo-cache";
    };

    shellInit = ''
      set -g theme_date_format "+%H:%M:%S "
      for file in ${pkgs.bobthefish}/lib/bobthefish/{functions/,}*.fish; . $file; end
    '';
  };
}
