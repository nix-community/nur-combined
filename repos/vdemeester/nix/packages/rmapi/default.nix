{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "rmapi-${version}";
  version = "0.0.19";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "juruen";
    repo = "rmapi";
    sha256 = "sha256-HXWE6688jhRQQEiZuPfuJStSQeueqoWwwa+PfneHprw=";
  };
  vendorHash = "Hash-gu+BU2tL/xZ7D6lZ1ueO/9IB9H3NNm4mloCZaGqZskU=";

  meta = {
    description = "Go app that allows you to access your reMarkable tablet files through the Cloud API";
    homepage = "https://github.com/juruen/rmapi";
    license = lib.licenses.gpl3;
  };
}
