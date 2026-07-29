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
  version = "0-unstable-2026-07-28";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "189322fc37a4407827f0f39de2c65ccc88f9c287";
    hash = "sha256-bDn+lM3NWLpUqg9pYai/OxMYi9o1dghQBtQ6IGb2tJo=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-VM4Vbv3kPAioe1z5JscAgVcytQFBOeQ7ewlJIDlDHTM=";

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
