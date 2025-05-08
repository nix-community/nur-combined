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
rustPlatform.buildRustPackage (ch57x-keyboard-tool: {
  pname = "ch57x-keyboard-tool";
  version = "1.5.4";

  src = fetchCrate {
    inherit (ch57x-keyboard-tool) pname version;
    sha256 = "sha256-i9UHMDptpptjqqycmsca7lri8tyiUPfyO2oV/nWicIc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-c+7U4SHAZy35QWKLF7v3e8CNQhJcORJIPQiks5UGltU=";

  postInstall = ''
    install -D ${rules} $out/etc/udev/rules.d/70-ch57x.rules
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for programming ch57x keyboard";
    homepage = "https://github.com/kriomant/ch57x-keyboard-tool";
    license = lib.licenses.mit;
  };
})
