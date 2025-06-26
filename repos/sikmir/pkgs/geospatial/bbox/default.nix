{
  lib,
  rustPlatform,
  fetchFromGitHub,
  buildPackages,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bbox";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "bbox-services";
    repo = "bbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FmY9Hqwv9lWjdEMe4JZM/nw8BaeZ+4eK+nibOUwcE+8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "pmtiles-0.12.0" = "sha256-wy22X51TcQOFxdXOInQxoL8DtFPqtV3pE0pQaEehtCA=";
    };
  };

  PROTOC = "${buildPackages.protobuf}/bin/protoc";

  cargoBuildFlags = [
    "--package"
    "bbox-server"
    "--package"
    "bbox-tile-server"
  ];

  meta = {
    description = "BBOX services";
    homepage = "https://github.com/bbox-services/bbox";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
  };
})
