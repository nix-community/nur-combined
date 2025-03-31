{
  lib,
  source,
  rustPlatform,
  pkg-config,
  pcsclite,
}:
rustPlatform.buildRustPackage {
  inherit (source) pname src;

  version = lib.replaceStrings [ "v" ] [ "" ] source.version;

  useFetchCargoVendor = true;

  cargoHash = "sha256-YZGrEO6SOS0Kir+1d8shf54420cYjvcfKYS+T2NlEug=";

  buildInputs = [ pcsclite.dev ];

  nativeBuildInputs = [
    pkg-config
  ];

  meta = {
    description = "Age plugin for using ed25519 on OpenPGP Card devices (Yubikeys, Nitrokeys";
    homepage = "https://github.com/wiktor-k/age-plugin-openpgp-card";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "age-plugin-openpgp-card";
  };
}
