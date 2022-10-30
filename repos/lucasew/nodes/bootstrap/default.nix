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
    ./screenkey.nix
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/3f8204a2aceef536a1c0cbbce8f8dde602b68ba2/nixos/modules/config/dotd.nix";
      sha256 = "1z1sjdjm7ciaps6ai5ms01vm2g35s9sxzgqqxjyr2wbz1x3x2gfs";
    })
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
