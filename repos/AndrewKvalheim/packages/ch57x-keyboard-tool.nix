{ fetchCrate
, lib
, nix-update-script
, rustPlatform
, writeText
}:

let
  rules = writeText "ch57x-udev-rules" ''
    ATTRS{idVendor}=="1189", ATTRS{idProduct}=="8890", MODE="0660", TAG+="uaccess"
  '';
in
rustPlatform.buildRustPackage rec {
  pname = "ch57x-keyboard-tool";
  version = "1.5.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-Ln/JqaV5hey2I6w2fEPgAMCWoOh7sqbWfDnjpOWa4fQ=";
  };
  cargoHash = "sha256-9mk02Oq2rkcDzZJ+RlZSBONJd1gnVF9ewM7emjxEzKk=";

  postInstall = ''
    install -D ${rules} $out/etc/udev/rules.d/70-ch57x.rules
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for programming ch57x keyboard";
    homepage = "https://github.com/kriomant/ch57x-keyboard-tool";
    license = lib.licenses.mit;
  };
}
