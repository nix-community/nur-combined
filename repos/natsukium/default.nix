# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { overlays = builtins.attrValues (import ./overlays); },
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  copyq = pkgs.copyq;
  emacs-plus = pkgs.callPackage ./pkgs/emacs-plus { source = sources.emacs-plus; };
  google-japanese-input = pkgs.callPackage ./pkgs/google-japanese-input { };
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon { source = sources.hammerspoon; };
  ligaturizer = pkgs.callPackage ./pkgs/ligaturizer { };
  nixpkgs-review = pkgs.nixpkgs-review;
  paperwm-spoon = pkgs.callPackage ./pkgs/paperwm-spoon { source = sources.paperwm-spoon; };
  psipred = pkgs.callPackage ./pkgs/psipred { };
  qmk-toolbox = pkgs.callPackage ./pkgs/qmk-toolbox { source = sources.qmk-toolbox; };
  qutebrowser = pkgs.qutebrowser;
  skills-ref = pkgs.callPackage ./pkgs/skills-ref { source = sources.skills-ref; };
  sbarlua = pkgs.callPackage ./pkgs/sbarlua { source = sources.sbarlua; };
  vivaldi = pkgs.vivaldi;
  zen-browser = pkgs.callPackage ./pkgs/zen-browser { source = sources.zen-browser; };
  liga-hackgen-font = pkgs.callPackage ./pkgs/data/fonts/liga-hackgen { inherit ligaturizer; };
  liga-hackgen-nf-font = liga-hackgen-font.override { nerdfont = true; };

  my-firefox-addons = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/firefox-addons {
      # buildFirefoxXpiAddon function vendored from https://gitlab.com/rycee/nur-expressions
      # Original source: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/default.nix
      # Licensed under MIT License
      # Copyright (c) Robert Helgesson
      # Vendored to avoid "path is not valid" errors when running `nix flake check --no-build` in downstream flakes
      buildFirefoxXpiAddon = pkgs.lib.makeOverridable (
        {
          pname,
          version,
          addonId,
          url,
          sha256,
          meta,
          ...
        }:
        pkgs.stdenv.mkDerivation {
          name = "${pname}-${version}";

          inherit meta;

          src = pkgs.fetchurl { inherit url sha256; };

          preferLocalBuild = true;
          allowSubstitutes = true;

          passthru = {
            inherit addonId;
          };

          buildCommand = ''
            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install -v -m644 "$src" "$dst/${addonId}.xpi"
          '';
        }
      );
    }
  );

  vimPlugins = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/vim-plugins {
      inherit (pkgs.vimUtils) buildVimPlugin;
      inherit sources;
    }
  );
}
