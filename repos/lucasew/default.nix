let
  flake = import (builtins.fetchurl {
    url = "https://raw.githubusercontent.com/edolstra/flake-compat/4112a081eff4b4d91d2db383c301780ee3c17b2b/default.nix";
    sha256 = "1a8jr0i6nxzg2wzv7cc5kg0979c5j7xbfjg94r2ljsyfpkzb23dc";
  }) { src = ./.; };
in
builtins.mapAttrs (k: v: v."${builtins.currentSystem}" or v) flake.defaultNix
