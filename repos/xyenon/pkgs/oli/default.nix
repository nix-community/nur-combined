{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2026-01-09";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "80dac5048a27fa64b1c74f48c0cfd56b12dccbe4";
    hash = "sha256-qFlgd3VN6uQAfyeQPvgnzCGdhCUDXptEIOLPYvMB35g=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-64FYjhuZs9qlbyjt390nO647wuY1MC8snyEPRT5FH+A=";

  checkFlags = [
    "--skip=edit::test_edit_file_content_replacement"
    "--skip=edit::test_edit_existing_file_with_changes"
    "--skip=edit::test_edit_new_file"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Unified and user-friendly way to manipulate data stored in various storage service";
    homepage = "https://opendal.apache.org/apps/oli/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "oli";
  };
}
