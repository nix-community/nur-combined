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
  version = "0-unstable-2026-06-01";
  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "cdd2234c2891f4cb6afd100e5b35b15d833c7451";
    hash = "sha256-hPY41HLXGXHW0DHcUlIZetjolZsNAhbXgFWQG1hEpZQ=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-Tf3ux3NRuLqm1fAkzSGW606Z6igW1KSe+KbA/dO0DPk=";

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
