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
      lgit = "git add -A; and git commit; and git push";
      lgitf = "git add -A; and git commit; and git pull; and git push";
      cdcc = "cd ~/.local/share/ccemux/computer/0";
      sysa = "sudo nixos-rebuild switch";
      sysu = "sudo nix-channel --update; sysa";
      sysuf = "cd $HOME/Projects/nixpkgs; git pull upstream master; cd -; sysa -I nixpkgs=$HOME/Projects/nixpkgs";
      sysclean = "sudo nix-collect-garbage -d; and sudo nix-store --optimise";
      ovpn = "sudo openvpn --config ~/.ovpn-client";
      argonsshr = "mosh --ssh=\"ssh -p 18903\" casper@argon";
      argonssh = "argonsshr tmux";
      qemu = "qemu-system-x86_64 -m 8192 --enable-kvm -smp (nproc --all) -vga virtio";
      cargo = "env LIBRARY_PATH=/run/current-system/sw/lib cargo";
      iotop = "sudo iotop";
      bmon = "sudo bmon";
      nix-shell-unstable = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
      aubuild = "nix-shell -p automake autoconf libtool --run \"sh autogen.sh\"; and nix-build .";
      esp-shell = "nix-shell (dotfiles)/esp-idf-shell.nix";
      vm-build = "sudo nixos-rebuild build-vm -p test -I nixos-config=./modules/hosts/nixos-qemu.nix";
      # TODO: try to find a way to persist the disk image without chown errors during VM boot.
      vm-run = "./result/bin/run-nixos-qemu-vm -m 4096 --enable-kvm --smp (nproc --all); and rm ./nixos-qemu.qcow2";
      ros = "xhost +; docker run $argv --cap-add=SYS_PTRACE -e DISPLAY=$DISPLAY --device /dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/casper/.Xauthority -v $PWD:/pwd --rm -it ros:melodic-custom; echo > /dev/null";
      ros-install = "docker build -t ros:melodic-custom (dotfiles)/ros-container";
    };

    shellInit = ''
      set -g theme_date_format "+%H:%M:%S "
      for file in ${pkgs.bobthefish}/lib/bobthefish/*.fish; . $file; end
    '';
  };
}
