{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "rmapi-${version}";
  version = "0.0.4";
  rev = "v${version}";

  goPackagePath = "github.com/juruen/rmapi";

  src = fetchFromGitHub {
    inherit rev;
    owner = "juruen";
    repo = "rmapi";
    sha256 = "0aarlsfvcakcmgv60g5qx6m9xji784xc21md5ap0zxsa9imyvxj8";
  };

  meta = {
    description = "Go app that allows you to access your reMarkable tablet files through the Cloud API";
    homepage = "https://github.com/juruen/rmapi";
    license = lib.licenses.gpl3;
  };
}
