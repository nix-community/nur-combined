{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "mods";
  version = "0.2.0";

  src = fetchgit {
    url = "https://github.com/charmbracelet/mods.git";
    rev = "v${version}";
    sha256 = "sha256-jOvXT/KAfSN9E4ZgntCbTu05VJu1jhGtv6gEgLStd98=";
  };

  vendorSha256 = "sha256-GNGX8dyTtzRSUznEV/do1H7GEf6nYf0w+CLCZfkktfg=";

  meta = with lib; {
    description = ''
       AI on the command line
    '';
    homepage = "https://github.com/charmbracelet/mods.git";
    license = licenses.mit;
  };
}
