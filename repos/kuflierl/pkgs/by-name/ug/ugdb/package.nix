{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  gdb,
  stdenv,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ugdb";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "ftilde";
    repo = "ugdb";
    tag = finalAttrs.version;
    hash = "sha256-6mlvr/2hqwu5Zoo9E2EfOmyg0yEGBi4jk3BsRZ+zkN8=";
  };

  cargoHash = "sha256-+J4gwjQXB905yk4b2GwpamXO/bHpwqMxw6GsnusbJKU=";

  propagatedBuildInputs = [
    gdb
  ];

  nativeCheckInputs = [
    gdb
  ];

  meta = {
    description = "ugdb is an unsegen based alternative TUI for gdb";
    homepage = "https://github.com/ftilde/ugdb";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    changelog = "https://github.com/ftilde/ugdb/blob/${finalAttrs.version}/CHANGELOG.md";
    mainProgram = "ugdb";
    broken = true;
    maintainers = with lib.maintainers; [ kuflierl ];
  };
})
