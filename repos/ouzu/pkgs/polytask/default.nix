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

  vendorSha256 = "sha256-s0zC6uZmSa0zQv6u7hiYX1HwI9IJe291i9hYawnp5fo=";
  
  meta = with lib; {
    description = "Taskwarrior module for polybar";
    homepage = "https://github.com/ouzu/polytask";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };
}