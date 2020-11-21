{ lib, buildGoPackage, lz4, sources }:

buildGoPackage rec {
  pname = "elevation-server-unstable";
  version = lib.substring 0 10 sources.elevation-server.date;

  src = sources.elevation-server;

  goPackagePath = "github.com/wladich/elevation_server";

  subPackages = [ "cmd/elevation_server" "cmd/make_data" ];

  buildInputs = [ lz4 ];

  goDeps = ./deps.nix;

  meta = with lib; {
    inherit (sources.elevation-server) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
