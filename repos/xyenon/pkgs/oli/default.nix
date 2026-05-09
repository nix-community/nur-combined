{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  cacert,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2026-05-07";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "fd6e9563272b49d23129bdc72bfdd7a2d73185b5";
    hash = "sha256-qd1/AQQaYMtCF/aFm8blyrXHhffsxRXqCwFdgCSa85Q=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-AcFqDL0+B9VU7j8OXb7P9Ke7H0rURxTaiKLFGwZU/1A=";

  nativeBuildInputs = [ cacert ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Unified and user-friendly way to manipulate data stored in various storage service";
    homepage = "https://opendal.apache.org/apps/oli/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "oli";
  };
}
