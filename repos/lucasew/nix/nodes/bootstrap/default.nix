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
    file
    tmux
    xclip
    killall
    script-directory-wrapper
    ;
in
{
  imports = [
    ./bash-extra.nix
    ./ccache.nix
    ./dotfiles-dir.nix
    ./rev.nix
    ./netns.nix
    ./nix-binary-caches.nix
    ./nixpkgs-symlink.nix
    ./nix.nix
    ./port-alloc.nix
    ./rev.nix
    ./screenkey.nix
    ./ssh.nix
    ./systemd-portd.nix
    ./tailscale.nix
    ./user.nix
    ./zerotier.nix
    ./nix-tmp.nix
    ./last-generation.nix
    ./dotd.nix
    ./kernel.nix
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
    file
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
    promptInit = builtins.concatStringsSep "\n" (
      map (builtins.readFile) [
        ./bash_init.sh
        ../../../config/.bashrc.d.tmpl/40-ui-prompt.sh
      ]
    );
  };
  networking.domain = lib.mkDefault "lucao.net";
}
