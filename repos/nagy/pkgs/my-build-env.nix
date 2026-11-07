{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  # Full NUR closure.  Required: modules/firefox.nix reads
  # nur.repos.rycee.firefox-addons.
  nur,
  # Private dotfiles tree.  Supplies (pkgs.callPackage dot).bin and dot/emacs.
  dot,
  # Optional extra NixOS module, for example a host-specific one.
  localModule ? null,
  # Flake inputs for the modules, for example flakes.emacs-bruvtab.  Empty
  # means NIX_PATH-free fallback to builtins.getFlake inside each module.
  flakes ? { },
}:

let
  self = import ./.. { inherit pkgs nur; };
  # From the flake input, or fetched directly so this file also works from
  # `nix-build`.
  jsonrpc-httpproxy = flakes.jsonrpc-httpproxy or (builtins.getFlake "github:nagy/jsonrpc-httpproxy");
  diffResult = self.lib.mkNixosBuildEnv {
    inherit nur flakes;
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
            # nur.repos.nagy.modules.common-lisp
            nur.repos.nagy.modules.desktop
            nur.repos.nagy.modules.emacs
            nur.repos.nagy.modules.firefox
            nur.repos.nagy.modules.fonts
            nur.repos.nagy.modules.fzf
            nur.repos.nagy.modules.git
            nur.repos.nagy.modules.go
            nur.repos.nagy.modules.gtk
            nur.repos.nagy.modules.hledger
            # nur.repos.nagy.modules.hmmodule-mpv
            # nur.repos.nagy.modules.hmmodule-readline
            # nur.repos.nagy.modules.hmmodule-zathura
            nur.repos.nagy.modules.htop
            nur.repos.nagy.modules.javascript
            nur.repos.nagy.modules.keyboard_layout
            nur.repos.nagy.modules.kubernetes
            nur.repos.nagy.modules.ncdu
            nur.repos.nagy.modules.neovim
            nur.repos.nagy.modules.nix
            nur.repos.nagy.modules.openstack
            nur.repos.nagy.modules.opentofu
            nur.repos.nagy.modules.ai
            nur.repos.nagy.modules.python
            # nur.repos.nagy.modules.pytr
            nur.repos.nagy.modules.restic
            nur.repos.nagy.modules.shortcommands_common
            nur.repos.nagy.modules.shortcommands
            # nur.repos.nagy.modules.ssh
            nur.repos.nagy.modules.starship
            nur.repos.nagy.modules.typst
            nur.repos.nagy.modules.xcompose
            nur.repos.nagy.modules.yggdrasil
          ]
          ++ lib.optional (localModule != null) localModule;

          environment.systemPackages = [
            pkgs.sqlite-interactive
            pkgs.duf
            pkgs.squashfsTools
            pkgs.qsv
            pkgs.rbw

            pkgs.playerctl
            pkgs.imagemagickBig
            pkgs.ocrmypdf
            pkgs.curl # to get newer versions
            pkgs.websocat
            self.ggufmeta
            (jsonrpc-httpproxy.packages.${pkgs.stdenv.hostPlatform.system}.jsonrpc-httpproxy)
            self.pngattach
            pkgs.libjxl
            pkgs.disko
            (pkgs.callPackage dot { inherit nur; }).bin
            pkgs.xh
            self.kicad-mcp-server
          ];

          services.xserver.enable = true;

          nagy.emacs = {
            packageDirectories = [
              (dot + "/emacs")
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
    fontconfigEnable
    fontconfigEtc
    fontsConf
    fontsCheck
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
  gitConfigSystem =
    if sys.config.environment.etc ? gitconfig then
      pkgs.writeText "gitconfig-system" sys.config.environment.etc.gitconfig.text
    else
      null;
  dockerConfigSystem =
    if sys.config.environment.etc ? "docker/config.json" then
      pkgs.writeTextFile {
        name = "docker-config";
        text = sys.config.environment.etc."docker/config.json".text;
        destination = "/config.json";
      }
    else
      null;
  # Agent sandbox config.  Same payload the NixOS module writes to
  # /etc/agent/config.json, so the sandbox picks it up without a rebuild.
  agentConfigFile =
    if sys.config.environment.etc ? "agent/config.json" then
      sys.config.environment.etc."agent/config.json".source
    else
      null;
  envScript = pkgs.writeTextFile {
    name = "my-build-env-script";
    destination = "/env.sh";
    text = ''
      export PATH="${buildEnv}/bin:$PATH"
      export MANPATH="${buildEnv}/share/man:$MANPATH"
      export INFOPATH="${buildEnv}/share/info:$INFOPATH"
      export NIX_PATH="nixpkgs=${lib.cleanSource pkgs.path}:$NIX_PATH"
      ${sessionVarExports}
      ${lib.optionalString (gitConfigSystem != null) "export GIT_CONFIG_SYSTEM=\"${gitConfigSystem}\""}
      ${lib.optionalString (dockerConfigSystem != null) "export DOCKER_CONFIG=\"${dockerConfigSystem}\""}
      ${lib.optionalString (agentConfigFile != null) "export AGENT_CONFIG=\"${agentConfigFile}\""}

      export TYPST_FONT_PATHS="${lib.makeSearchPath "share/fonts/opentype" sys.config.fonts.packages}"
      ${lib.optionalString fontconfigEnable ''
        export FONTCONFIG_FILE="${fontsConf}"
        export FONTCONFIG_PATH="${fontconfigEtc}"
      ''}

    '';
  };
in
pkgs.buildEnv {
  name = "my-build-env";
  paths = [
    buildEnv
    envScript
  ];
  passthru = {
    inherit
      buildEnv
      envScript
      agentConfigFile
      fontconfigEnable
      fontconfigEtc
      fontsConf
      fontsCheck
      ;
  };
}
