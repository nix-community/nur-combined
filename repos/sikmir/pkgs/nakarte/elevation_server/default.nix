{ lib, fetchFromGitHub, buildGoPackage, lz4 }:

buildGoPackage rec {
  pname = "elevation_server";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = pname;
    rev = version;
    sha256 = "sha256-2mpBboPKIV+Wm2p3FHy3a+6H3+qJUOu2+F28MufzBwU=";
  };

  goPackagePath = "github.com/wladich/elevation_server";

  subPackages = [ "cmd/elevation_server" "cmd/make_data" ];

  buildInputs = [ lz4 ];

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "The server providing elevation data";
    homepage = "https://github.com/wladich/elevation_server";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
