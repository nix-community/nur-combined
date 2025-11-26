{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2025-11-26";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "bb2c686a170c3286a809bcfb304964db458606ea";
    hash = "sha256-XI3HEDw/iutiJ/NELj/yVJpS4ieaGCL33ZU1+bRP1xY=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-p7L9XPZo9Yv/dwimFkQOwp2MtE2JTFhEeA7gBwYVjlY=";

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
