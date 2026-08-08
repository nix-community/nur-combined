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
  version = "0-unstable-2026-08-07";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "3d6e427e8c0c92aec1430e2f4bbb777e4e08d81e";
    hash = "sha256-X6QOFs94jOQeZySmSyWP3VVgPyWNC8ihW2IFu9loKR0=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-58pYGU1XwP3AsEugeXuqPmPuXGXSwVz/Aq7KaKAfNtQ=";

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
