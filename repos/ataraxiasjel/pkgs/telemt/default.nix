{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  aws-lc,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.5.17";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-P7YfANtmuv/g1K6WtoNVSwXOEtf8kYzJt6MVJ4fv9sk=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ aws-lc ];

  cargoHash = "sha256-cThWDXZRe3vb/+ptYU0mu82+LfSao4omdEC0LOERvbw=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MTProxy for Telegram on Rust + Tokio";
    homepage = "https://github.com/telemt/telemt";
    license = licenses.unfree;
    mainProgram = "telemt";
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = platforms.linux;
  };
})
