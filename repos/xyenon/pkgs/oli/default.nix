{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "4ecce3beb63c085b84a396b0f06c22fed77284e7";
    hash = "sha256-2bS3SYRdJxljQoKoeOqkrzMsv6mvBamO2S7TTlvCOgc=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-TEcOEX4KX184wq8saClupOLbme3x0+0a3pgil2rvq60=";

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
