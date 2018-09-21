{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

let
  owner = "adnanh";
  repo = "webhook";
  version = "2.6.8";
  sha256 = "05q6nv04ml1gr4k79czg03i3ifl05xq29iapkgrl3k0a36czxlgs";
  description = "Webhook is a lightweight configurable incoming webhook server which can execute shell commands";
  license = stdenv.lib.licenses.mit;
in buildGoPackage rec {
  name = "${repo}-${version}";
  goDeps = ./deps.nix;
  goPackagePath = "github.com/${owner}/${repo}";

  src = fetchFromGitHub {
    inherit owner repo sha256;
    rev = version;
  };

  meta = with stdenv.lib; {
    inherit description license;
    homepage = https:// + goPackagePath;
  };
}
