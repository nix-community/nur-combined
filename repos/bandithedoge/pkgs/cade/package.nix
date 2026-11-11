{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  pname = "cade";
  version = "0.1.3-unstable-2026-11-11";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "195795d8cd9ad24bb1dc01c1074f6ea65f9dd869";
    hash = "sha256-/knskto2VV0NQ5iCfQuF4fZ5KZw/fOMY5Q3JVs861cY=";
  };

  cargoHash = "sha256-uKiiMAe8U4s3V14GLoGOgpLfwP5cdPK8BSfI/fwsxw0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Intelligent, cascading environment manager";
    homepage = "https://github.com/manic-systems/cade";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "cade";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
