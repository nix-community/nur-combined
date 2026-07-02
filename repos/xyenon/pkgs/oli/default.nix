{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  cacert,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  __structuredAttrs = true;

  pname = "oli";
  version = "0-unstable-2026-07-01";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "e84ce9e234706438648b128b6acd3a43bf66b536";
    hash = "sha256-dO/Yu0r2uZjN38hqYmYc+BqW/7f6cy16nI1SKZUTZOg=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-tjTeFoO7MnOLJVRLGgkXNT7XKUojE0KKqPk6aVvHVS0=";

  nativeCheckInputs = [ cacert ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Unified and user-friendly way to manipulate data stored in various storage service";
    homepage = "https://opendal.apache.org/apps/oli/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "oli";
  };
}
