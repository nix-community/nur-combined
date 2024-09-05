{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  lz4,
}:

buildGoModule rec {
  pname = "elevation_server";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "sikmir";
    repo = "elevation_server";
    rev = "d8964ed01e81dea4bcd20cf6f7e092da4b2d5547";
    hash = "sha256-nckgsaXtLd1D3gYqdAMF5VRRM4zkw4G6R0P//G9lqDM=";
  };

  vendorHash = "sha256-j43mafIXC1C4RvVIoqTV44kWSJgv1WDRphX3/G29Uxk=";

  subPackages = [
    "cmd/elevation_server"
    "cmd/make_data"
  ];

  buildInputs = [ lz4 ];

  meta = {
    description = "The server providing elevation data";
    homepage = "https://github.com/wladich/elevation_server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "elevation_server";
  };
}
