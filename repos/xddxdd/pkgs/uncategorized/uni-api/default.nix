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
  version = "1.7.276-unstable-2026-11-10";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "5ad32254db3fad19c75b5cf416d7972f31bba28d";
    hash = "sha256-TTnhgCecjluSBYMdEBqh3MzrWVY3ypK69Oo1qrZiS0Y=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-Yw6uTa0pRmAl2UAK1jzaDM0sBM9FYVK5mIzQmN7A3ZE=";

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
