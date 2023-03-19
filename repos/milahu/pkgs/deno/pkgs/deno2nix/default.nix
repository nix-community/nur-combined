{ pkgs
, fetchFromGitHub
}:

# TODO simpler
# https://github.com/SnO2WMaN/deno2nix/issues/11

let

  deno2nix-src = fetchFromGitHub {
    # https://github.com/SnO2WMaN/deno2nix
    owner = "SnO2WMaN";
    repo = "deno2nix";
    rev = "fa15d03cdbf6483cb2c71f1f0226fc611b27a906";
    sha256 = "sha256-866YtYs1yr5OvFTw0Lex8qwBfrNxE0+1W1hWzcoUmo0=";
  };

in

(import (deno2nix-src + "/nix/overlay.nix") pkgs {}).deno2nix
