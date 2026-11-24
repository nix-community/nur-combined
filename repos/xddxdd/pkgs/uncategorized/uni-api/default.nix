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
  version = "1.7.276-unstable-2026-11-24";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "90d8adda327f3d07f124e56f96d170fc6031956d";
    hash = "sha256-SMWBmvPfWBVjUxrmTDMr9QFnC3JrutypJoP2IwxVqBg=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-tmGv9BCYYex6HEiQ2tgEXXW0EIl7OTQ21fwVjHHJ7m0=";

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
