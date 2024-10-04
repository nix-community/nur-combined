{ lib

, fetchFromGitHub

, rustPlatform

, pkg-config

, libsodium
}:
rustPlatform.buildRustPackage rec {
  pname = "agree";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "replicadse";
    repo = "agree";
    rev = version;
    hash = "sha256-4UW4GblEnpAOvceU+ugVbdOcMRN8Ijy1OEeuzR5RJLU=";
  };

  cargoHash = "sha256-OB4bQoOTj/xp4Bf+HsKq3SxGWVW8QtIAPA1zBWAHTtA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libsodium
  ];

  env = {
    SODIUM_USE_PKG_CONFIG = true;
  };

  meta = with lib; {
    description = "A CLI application that implements multi-key-turn security via Shamir's Secret Sharing";
    homepage = "https://github.com/replicadse/agree";
    license = licenses.mit;
    mainProgram = "agree";
  };
}
