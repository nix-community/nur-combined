{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  zstd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "206eecf3d40ae103e2d2cf06c0987689ba3208ed";
    hash = "sha256-iaBxSo5aiOcmWXv/lQTJP5apax2iI94NsrSf8Ektbkw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-Cq6rUQRp7pQ+XjNhh1gm6e5nWF0wNRY77DYCy3DLmNY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    zstd
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
