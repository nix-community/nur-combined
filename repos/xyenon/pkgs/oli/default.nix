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
  version = "0-unstable-2026-09-02";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "2a2b2579d905ed539bd313fac033f6cdb7913a44";
    hash = "sha256-nB1quX6cWlzJfgMdnh+kmqj9Ao9u9ZoFKc5zbe66/i8=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-kNx0y8zS8MgCVomzDK6Hh+r6XBTfpnlDX6aU4VeeBMg=";

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
