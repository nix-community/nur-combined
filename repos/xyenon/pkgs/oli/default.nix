{
  lib,
  rustPlatform,
  fetchgit,
  runtimeShell,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oli";
  version = "0.54.1";

  # Cannot use `fetchFromGitHub` because `bin` is marked as `export-ignore`.
  src = fetchgit {
    url = "https://github.com/apache/opendal.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NaKUIL6TUZc3HjYNNEofmmydgDT8yjIczgtzBd23Ku4=";
  };
  sourceRoot = "${finalAttrs.src.name}/bin/oli";

  postPatch = ''
    substituteInPlace tests/integration/edit.rs --replace-warn '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-zJYMZ1hsiN4TOuRZAlgzm7NHBYRmfCqr8jlpfW/CROU=";

  checkFlags = [
    "--skip=edit::test_edit_file_content_replacement"
    "--skip=edit::test_edit_existing_file_with_changes"
    "--skip=edit::test_edit_new_file"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unified and user-friendly way to manipulate data stored in various storage service";
    homepage = "https://opendal.apache.org/apps/oli/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "oli";
  };
})
