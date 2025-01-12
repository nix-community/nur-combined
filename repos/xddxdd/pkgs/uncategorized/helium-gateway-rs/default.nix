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

  cargoHash = "sha256-bqAzX0djA3SpDnmyLiwanFAlwZRi4nmYB7akBGMkZTM=";
  useFetchCargoVendor = true;

  meta = {
    mainProgram = "helium_gateway";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Helium Gateway";
    homepage = "https://github.com/helium/gateway-rs";
    license = lib.licenses.asl20;
  };
}
