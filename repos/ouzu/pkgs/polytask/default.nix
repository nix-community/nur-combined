{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "polytask";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "polytask";
    rev = "v${version}";
    sha256 = "sha256-lT3EJhHVsGsRAR63t1yh/OMkKFAZc1uxWjtW5fzyfjU=";
  };

  vendorSha256 = "sha256-BZ0GO3T6X23jgbMR/3KiOGbJeEH5Yn/8mbvbHD+Nzo0=";
  
  meta = with lib; {
    description = "Taskwarrior module for polybar";
    homepage = "https://github.com/ouzu/polytask";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };
}