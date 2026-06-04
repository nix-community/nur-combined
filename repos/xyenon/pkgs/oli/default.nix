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
  version = "0-unstable-2026-06-03";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "32f1cc2b5840718a26b286f8b2b8975401f7e720";
    hash = "sha256-jsWtl+OchX6tgoyr1xCzZZfpA3UzcCfTzwl7Xc1sojU=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-gA3Yp727W80IdUWwVIw/xeIB8bGSEIHnFYciuNy0mAI=";

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
