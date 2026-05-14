{ fetchCrate
, lib
, nix-update-script
, rustPlatform
, versionCheckHook
}:

let
  inherit (lib) licenses;
in
rustPlatform.buildRustPackage (oxvg: {
  pname = "oxvg";
  version = "0.0.5";
  meta = {
    description = "Rust alternative to SVGO";
    homepage = "https://github.com/noahbald/oxvg";
    license = licenses.mit;
    mainProgram = "oxvg";
  };

  passthru.updateScript = nix-update-script { };

  src = fetchCrate {
    inherit (oxvg) pname version;
    sha256 = "sha256-I52L0cbj7BYdHVVhJEdhT28DRTg/f7eWpN0qGxfSdhQ=";
  };

  cargoHash = "sha256-+dfM2/SjUTwNAoKC7cjw2Ba1RNp6BwmbR1TxXtp9W4E=";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
