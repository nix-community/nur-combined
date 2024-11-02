{
  sources,
  lib,
  rustPlatform,
  protobuf,
}:
rustPlatform.buildRustPackage {
  inherit (sources.helium-gateway-rs)
    pname
    version
    rawVersion
    src
    ;

  PROTOC = "${protobuf}/bin/protoc";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "beacon-0.1.0" = "sha256-xSqLhnlRKJ2BCeyNjuj6q0Ug2V7YRvHfyeJ9u1fiijM=";
      "exponential-backoff-1.2.0" = "sha256-bJkKb5Muja6HkwyXkD+4kfQxM/aRFH/KqvVPvMt20L0=";
    };
  };

  meta = with lib; {
    mainProgram = "helium_gateway";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Helium Gateway";
    homepage = "https://github.com/helium/gateway-rs";
    license = licenses.asl20;
  };
}
