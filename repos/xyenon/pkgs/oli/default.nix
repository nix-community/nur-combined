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
  version = "0-unstable-2026-08-05";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "6228e7747a1edc90cafa5619c576416c2f1bf734";
    hash = "sha256-9BIKWT/CTcbIqBbBavyJYSAROL9vYnDDrGkXDP1OVA8=";
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
