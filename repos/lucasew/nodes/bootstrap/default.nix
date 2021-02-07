{pkgs, ...}:
with import ../../globalConfig.nix;
{
  nix = {
    trustedUsers = [username "@wheel"];
    package = pkgs.nixFlakes;
    autoOptimiseStore = true;
    gc = {
      options = "--delete-older-than 15d";
    };
    extraOptions = ''
      min-free = ${toString (1  * 1024*1024*1024)}
      max-free = ${toString (10 * 1024*1024*1024)}
      experimental-features = nix-command flakes
    '';
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 20;
  };
  nixpkgs.config.allowUnfree = true;
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = with pkgs; [
    rclone
    restic
    neovim
  ];
  environment.variables.EDITOR = "nvim";
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    authorizedKeysFiles = [
      (builtins.toString ../../authorized_keys)
    ];
  };
  services.zerotierone = {
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
    };
  };
  services.irqbalance.enable = true;
}
