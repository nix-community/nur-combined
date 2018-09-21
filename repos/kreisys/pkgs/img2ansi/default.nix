{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

let
  repo        = "img2ansi";
  description = "Converts an image to ANSI (using SGR escape sequences)";

  # It's not actually version 1.0.0, it looks like an abandoned project with no versioned releases
  owner   = "lloiser";
  version = "1.0.0";
  rev     = "1b5600c638db787130d33940b4ea4349dd5517d5";
  sha256  = "1936ha6avvqjpq2ypl4aplvss3w3gblrf641yvnwinlfmzq9w9ig";
  license = stdenv.lib.licenses.mit;

in buildGoPackage rec {
  name = "${repo}-${version}";
  goDeps = ./deps.nix;
  goPackagePath = "github.com/${owner}/${repo}";

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };

  meta = with stdenv.lib; {
    inherit description license;
    homepage = https:// + goPackagePath;
  };
}
