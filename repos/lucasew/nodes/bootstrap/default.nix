{global, pkgs, lib, ...}:
let
  inherit (pkgs) vim nixFlakes writeText gitMinimal tmux xclip;
  inherit (global) username;
in {
  nix = {
    settings = {
      trusted-users = [username "@wheel"];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = [
    vim
    gitMinimal
    tmux
    xclip
  ];
  environment.variables.EDITOR = "nvim";
  # remote acess
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };
  programs.mosh.enable = true;
  services.zerotierone = {
    enable = true;
    port = 6969;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.extraHosts = ''
    192.168.69.1 vps.local
    192.168.69.1 utils.vps.local
    192.168.69.1 vaultwarden.vps.local
    192.168.69.1 *.vps.local
    192.168.69.2 nb.local
    192.168.69.3 mtpc.local
    192.168.69.4 cel.local
  '';
  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      initialPassword = "changeme";
      openssh.authorizedKeys.keyFiles = [
        ../../authorized_keys
      ];
    };
  };
  security.sudo.extraConfig = ''
Defaults lecture = always

Defaults lecture_file=${writeText "sudo-lecture" ''
It's sudo time!
''}
  '';
}
