{global, pkgs, lib, self, ...}:
let
  inherit (pkgs) vim gitMinimal tmux xclip writeShellScriptBin;
  inherit (global) username;
in {
  imports = [
    ./flake-etc.nix
    ./nix.nix
    ./zerotier.nix
    ./user.nix
    ./ssh.nix
    ./colors.nix
    ./motd.nix
  ];
  
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = [
    vim
    gitMinimal
    tmux
    xclip
  ];
  environment.variables = {
    EDITOR = "nvim";
  };
  programs.bash = {
    promptInit = builtins.readFile ./bash_init.sh;
  };
  networking.domain = lib.mkDefault "lucao.net";
}
