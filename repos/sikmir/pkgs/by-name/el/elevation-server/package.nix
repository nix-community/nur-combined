{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  lz4,
}:

buildGoModule {
  pname = "elevation-server";
  version = "1.2.0-unstable-2024-09-11";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "elevation_server";
    rev = "649297b32615f35e2c14d3c43216100ab4d83ea4";
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
