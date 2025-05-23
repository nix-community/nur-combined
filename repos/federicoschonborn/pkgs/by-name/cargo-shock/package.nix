{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "cargo-shock";
  version = "0-unstable-2025-05-22";

  src = fetchFromGitHub {
    owner = "funkeleinhorn";
    repo = "cargo-shock";
    rev = "701be4d703652533d3a3f7cc98f098d29ed9fe9b";
    hash = "sha256-UaAdFMQm1lS/INHxNU52vHjTYJJpbZ1P8iLjtI9mHHA=";
  };

  useCargoFetchVendor = true;
  cargoHash = "sha256-K0C0CgHxvssJXM4zfcFbocwWxpGld4B5z/GnziuVOnw=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "When writing Rust is not hurtful enough";
    homepage = "https://github.com/funkeleinhorn/cargo-shock";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    mainProgram = "cargo-shock";
  };
}
