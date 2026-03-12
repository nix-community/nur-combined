{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "oli";
  version = "0-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "opendal-oli";
    rev = "79b3b365bab60758f5c4676b5f4e8637c8884a3e";
    hash = "sha256-JdctM/sNXBYSCStajtl0qXzoNaMEBHhONq4pdtMYE5o=";
  };

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-+3HlkFYn4zqxk32q2xIhegvsFpWXYnbkzixBVbT52mg=";

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
