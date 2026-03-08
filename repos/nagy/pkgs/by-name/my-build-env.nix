{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  nixosEval ? import <nixpkgs/nixos/lib/eval-config.nix>,
}:

let
  self = import ../.. { inherit pkgs; };
  specialArgs = {
    nur = import <nur> {
      nurpkgs = pkgs;
      pkgs = pkgs;
      repoOverrides = {
        nagy = self;
      };
    };
  };
  sysEmpty = nixosEval {
    inherit specialArgs;
    modules = [
      {
        system.stateVersion = "26.05";
      }
    ];
  };
  sys = nixosEval {
    inherit specialArgs;
    modules = [
      (
        {
          config,
          pkgs,
          nur,
          ...
        }:
        {
          imports = [
            nur.repos.nagy.modules.alacritty
            nur.repos.nagy.modules.common-lisp
            # nur.repos.nagy.modules.common
            # nur.repos.nagy.modules.coredns
            nur.repos.nagy.modules.desktop
            nur.repos.nagy.modules.emacs
            # nur.repos.nagy.modules.firefox
            nur.repos.nagy.modules.fonts
            nur.repos.nagy.modules.fzf
            nur.repos.nagy.modules.git
            nur.repos.nagy.modules.go
            nur.repos.nagy.modules.gtk
            nur.repos.nagy.modules.hledger
            # nur.repos.nagy.modules.hmconvert
            nur.repos.nagy.modules.hmmodule-mpv
            nur.repos.nagy.modules.hmmodule-readline
            nur.repos.nagy.modules.hmmodule-zathura
            nur.repos.nagy.modules.htop
            nur.repos.nagy.modules.javascript
            nur.repos.nagy.modules.keyboard_layout
            # nur.repos.nagy.modules.kubernetes
            # nur.repos.nagy.modules.lua
            nur.repos.nagy.modules.ncdu
            nur.repos.nagy.modules.nix
            nur.repos.nagy.modules.opentofu
            nur.repos.nagy.modules.python
            nur.repos.nagy.modules.pytr
            nur.repos.nagy.modules.restic
            nur.repos.nagy.modules.rust
            nur.repos.nagy.modules.shortcommands_common
            nur.repos.nagy.modules.shortcommands
            nur.repos.nagy.modules.ssh
            nur.repos.nagy.modules.starship
            nur.repos.nagy.modules.typst
            # nur.repos.nagy.modules.wasm
            nur.repos.nagy.modules.xcompose
            nur.repos.nagy.modules.yggdrasil
          ];

          environment.systemPackages = [
            pkgs.sqlite-interactive
            pkgs.duf
            pkgs.squashfsTools
            pkgs.qsv
          ];

          services.xserver.enable = true;

          environment.sessionVariables.XAUTHORITY = lib.mkDefault "/run/user/1000/Xauthority";

          nagy.shortcommands = {
            enable = true;
          };

          nagy.emacs = {
            packageDirectories = [
              (if (lib.pathExists ~/dotfiles/emacs) then ~/dotfiles/emacs else <dot/emacs>)
            ];
          };

          system.stateVersion = "26.05";
        }
      )
    ];
  };
  newpkgs = lib.lists.filter (
    x: !(lib.elem x sysEmpty.config.environment.systemPackages)
  ) sys.config.environment.systemPackages;

  myBuildEnv = pkgs.buildEnv {
    name = "my-build-env";
    paths = newpkgs;
  };
in
pkgs.writeText "my-build-env-script" ''
  export PATH="${myBuildEnv}/bin:$PATH"
  export MANPATH="${myBuildEnv}/share/man:$MANPATH"
  export INFOPATH="${myBuildEnv}/share/info:$INFOPATH"
  export NIX_PATH="nixpkgs=${lib.cleanSource pkgs.path}:$NIX_PATH"

  # TODO make this dynamic
  export TYPST_FONT_PATHS="${lib.makeSearchPath "share/fonts/opentype" sys.config.fonts.packages}"

  # TODO make this dynamic
  export TERMINFO_DIRS="${pkgs.emacs.pkgs.eat}/share/emacs/site-lisp/elpa/eat-${pkgs.emacs.pkgs.eat.version}/terminfo:$TERMINFO_DIRS"
''
