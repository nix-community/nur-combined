{ config, pkgs, lib, ... }:

{
  # Never use nano.
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
      clip = "xclip -selection clipboard";
      qemu = "qemu-system-x86_64 -m 4096 --enable-kvm -smp (nproc --all)";
      cargo = "env LIBRARY_PATH=/run/current-system/sw/lib cargo";
      iotop = "sudo iotop";
      bmon = "sudo bmon";
      fslist = "zfs list -o name,compressratio,used,available";
      aubuild = "nix-shell -p automake autoconf libtool --run \"sh autogen.sh\"; and nix-build .";
      esp-shell = "nix-shell (dotfiles)/esp-idf-shell.nix";
    };

    shellInit = ''
      set -g theme_date_format "+%H:%M:%S "
      for file in ${pkgs.bobthefish}/lib/bobthefish/*.fish; . $file; end
    '';
  };
}
