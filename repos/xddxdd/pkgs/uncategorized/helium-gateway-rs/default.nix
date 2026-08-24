{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  protobuf,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "helium-gateway-rs";
  version = "1.3.0-unstable-2025-04-11";
  src = fetchFromGitHub {
    owner = "helium";
    repo = "gateway-rs";
    rev = "b736b006af618d67433e0d4c19d626260fad6dcb";
    hash = "sha256-Q4wJJIIk59qI9NNnxUIBDBZFFFvjuUFCJAfCdtFMdGU=";
  };
  PROTOC = "${protobuf}/bin/protoc";

  cargoHash = "sha256-CvjbgGfphDk61BnKkKWOUXL8pbofz/EDsABaW+QUWec=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = "helium_gateway";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Helium Gateway";
    homepage = "https://github.com/helium/gateway-rs";
    license = lib.licenses.asl20;
  };
})
