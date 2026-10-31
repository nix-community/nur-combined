{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "aeroflare";
  version = "1.15.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "itzemoji";
    repo = "aeroflare";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FuDEOCvJcLUI4Ot9q32M4GiD/oxcwSRg03BDTSvM4Fw=";
  };

  vendorHash = "sha256-H4jgc08mklolpHQNlcQx5JzpCDBYpujgoKFR2Ct8xR8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/itzemoji/aeroflare/internal/build.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/aeroflare"
    "cmd/aeroflare-ci"
  ];
  versionCheckProgramArg = "version";

  meta = {
    description = "OCI-based Nix-Binary-Cache written in Go";
    homepage = "https://github.com/itzemoji/aeroflare";
    changelog = "https://github.com/itzemoji/aeroflare/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl3Only;
    mainProgram = "aeroflare";
  };
})
