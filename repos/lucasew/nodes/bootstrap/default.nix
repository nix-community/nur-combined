{pkgs, ...}:
with import ../../globalConfig.nix;
{
  nix = {
    trustedUsers = [username "@wheel"];
    package = pkgs.nixFlakes;
    extraOptions = ''
      min-free = ${toString (1  * 1024*1024*1024)}
      max-free = ${toString (10 * 1024*1024*1024)}
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = with pkgs; [
    neovim
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
  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      openssh.authorizedKeys.keyFiles = [
        ../../authorized_keys
      ];
    };
  };
  security.sudo.extraConfig = ''
Defaults lecture = always

Defaults lecture_file=${pkgs.writeText "sudo-lecture" ''
It's sudo time!
''}
  '';
}
