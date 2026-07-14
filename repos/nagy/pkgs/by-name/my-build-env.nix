{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

let
  nixpaths = builtins.listToAttrs (
    builtins.map (x: {
      name = x.prefix;
      value = x.path;
    }) builtins.nixPath
  );
  self = import ../.. { inherit pkgs; };
  diffResult = self.lib.mkNixosBuildEnv {
    name = "my-build-env";
    targetModules = [
      (
        {
          # config,
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
            nur.repos.nagy.modules.kubernetes
            nur.repos.nagy.modules.llama-cpp
            # nur.repos.nagy.modules.lua
            nur.repos.nagy.modules.ncdu
            nur.repos.nagy.modules.nix
            nur.repos.nagy.modules.openstack
            nur.repos.nagy.modules.opentofu
            nur.repos.nagy.modules.pi-coding-agent
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
          ]
          ++ (lib.optionals (nixpaths ? "local-module") [
            <local-module>
          ]);

          environment.systemPackages = [
            pkgs.sqlite-interactive
            pkgs.duf
            pkgs.squashfsTools
            pkgs.qsv
            pkgs.rbw

            pkgs.playerctl
            self.nanoid-cli
            pkgs.imagemagickBig
            pkgs.ocrmypdf
            pkgs.curl # to get newer versions
            pkgs.websocat
            self.ggufmeta
            (pkgs.callPackage (builtins.fetchGit {
              url = "https://github.com/nagy/jsonrpc-httpproxy";
              ref = "master";
            }) { })
            pkgs.ron-lsp
          ];

          services.xserver.enable = true;

          nagy.emacs = {
            packageDirectories = [
              <dot/emacs>
            ];
          };
        }
      )
    ];
  };
  inherit (diffResult)
    sys
    buildEnv
    diffedSessionVariables
    diffedFontPackages
    ;

  sessionVarExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "export ${name}=\"${value}\"") (
      lib.filterAttrs (
        n: _:
        !(lib.elem n [
          "TERMINFO_DIRS"
          "NIX_PATH"
        ])
      ) diffedSessionVariables
    )
  );
in
pkgs.writeText "my-build-env-script" ''
  export PATH="${buildEnv}/bin:$PATH"
  export MANPATH="${buildEnv}/share/man:$MANPATH"
  export INFOPATH="${buildEnv}/share/info:$INFOPATH"
  export NIX_PATH="nixpkgs=${lib.cleanSource pkgs.path}:$NIX_PATH"
  ${sessionVarExports}

  export TYPST_FONT_PATHS="${lib.makeSearchPath "share/fonts/opentype" diffedFontPackages}"

  # TODO make this dynamic
  export TERMINFO_DIRS="${pkgs.emacs.pkgs.ghostel}/share/emacs/site-lisp/elpa/ghostel-${pkgs.emacs.pkgs.ghostel.version}/etc/terminfo:$TERMINFO_DIRS"
''
