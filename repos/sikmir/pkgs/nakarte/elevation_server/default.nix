{ lib, stdenv, fetchFromGitHub, buildGoPackage, lz4 }:

buildGoPackage rec {
  pname = "elevation_server";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "elevation_server";
    rev = version;
    hash = "sha256-2mpBboPKIV+Wm2p3FHy3a+6H3+qJUOu2+F28MufzBwU=";
  };

  goPackagePath = "github.com/wladich/elevation_server";

  subPackages = [ "cmd/elevation_server" "cmd/make_data" ];

  buildInputs = [ lz4 ];

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "The server providing elevation data";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
