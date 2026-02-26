{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2026-02-24";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "f74cb15ee00e07f422455ff36ac7128784c55f16";
    hash = "sha256-7RnzJc432uDjy+7j7/spsaaly+LnfzQ0mKKdQ875MX4=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-q4RPQTOoI7hP5f/ICPCEVZY8/xaJvCRiPL1/OkD0pnk=";

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
