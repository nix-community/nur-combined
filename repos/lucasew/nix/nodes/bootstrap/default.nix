{
  global,
  pkgs,
  lib,
  self,
  config,
  ...
}:
let
  inherit (pkgs)
    vim
    gitMinimal
    tmux
    xclip
    killall
    script-directory-wrapper
    ;
  inherit (global) username;
in
{
  imports = [
    ./bash-extra.nix
    ./colors.nix
    ./ccache.nix
    ./dotfiles-dir.nix
    ./motd.nix
    ./netns.nix
    ./nix-binary-caches.nix
    ./nixpkgs-symlink.nix
    ./nix.nix
    ./port-alloc.nix
    ./rev.nix
    ./screenkey.nix
    ./script-directory.nix
    ./ssh.nix
    ./systemd-portd.nix
    ./tailscale.nix
    ./user.nix
    ./zerotier.nix
    ./nix-tmp.nix
    ./last-generation.nix
    ./dotd.nix
  ];

  networking.firewall.allowedTCPPorts = [
    7879 # rclone DLNA
  ];

  boot.tmp.cleanOnBoot = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = [
    vim
    gitMinimal
    tmux
    xclip
    killall
    script-directory-wrapper
  ];
  environment.variables = {
    EDITOR = "hx";
    PATH = "$PATH";
  };
  programs.bash = {
    promptInit = builtins.readFile ./bash_init.sh;
  };
  networking.domain = lib.mkDefault "lucao.net";
}
