{pkgs, lib, ...}: {
  nix = {
    settings = {
      trusted-users = [ "fulano" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment = {
    systemPackages = with pkgs; [ vim direnv ];
    variables.EDITOR = "vim";
    variables.NIX_PATH = lib.mkForce ("nixpkgs=" + pkgs.path);
  };
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };
  users.users.fulano = { # criação de usuários
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "123";
  };
  security.sudo.extraConfig = ''
    Defaults lecture = always
      Defaults lecture_file=${pkgs.writeText "sudo-lecture" ''
        Sudo time!
      ''}
  '';
  environment.etc."helloworld".text = "hello!"; # criação de arquivo no /etc
  programs.bash = {
    promptInit = ''
      export PS1="\u@\h \w \$?\\$ \[$(tput sgr0)\]"
      eval "$(direnv hook bash)"
    '';
  };

  boot.plymouth = {
    enable = true;
  };

  networking.hostName = "tcc";
  networking.networkmanager.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "20.03";

}
