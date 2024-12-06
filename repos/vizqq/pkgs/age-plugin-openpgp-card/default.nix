{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  pcsclite,
}:
rustPlatform.buildRustPackage {
  pname = "age-plugin-openpgp-card";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "wiktor-k";
    repo = "age-plugin-openpgp-card";
    rev = "a8d782551825e5062d53011b5f827d39637bda3b";
    hash = "sha256-uJmYtc+GxJZtCjLQla/h9vpTzPcsL+zbM2uvAQsfwIY=";
  };

  cargoHash = "sha256-mf06DLuTeyhTW796SRZh130QXDLfVSnDQyGQgKbOZH0=";

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
