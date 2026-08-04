{ fetchCrate
, lib
, nix-update-script
, rustPlatform
, versionCheckHook
, writeText
}:

let
  rules = writeText "ch57x-udev-rules" ''
    ATTRS{idVendor}=="1189", ATTRS{idProduct}=="8890", MODE="0660", TAG+="uaccess"
  '';
in
rustPlatform.buildRustPackage (ch57x-keyboard-tool: {
  pname = "ch57x-keyboard-tool";
  version = "1.8.0";
  meta = {
    description = "Command-line tool for programming ch57x keyboard";
    homepage = "https://github.com/kriomant/ch57x-keyboard-tool";
    license = lib.licenses.mit;
  };

  passthru.updateScript = nix-update-script { };

  src = fetchCrate {
    inherit (ch57x-keyboard-tool) pname version;
    sha256 = "sha256-0AtZG9ASDLtqKFpeR9zhbfxu4hTK9o7BOJ0ZpzErR7A=";
  };

  cargoHash = "sha256-OIyS7uLxijM3bZj6656ShTqF3UR0VpkXMRcauFujoxk=";

  postInstall = ''
    install -D ${rules} "$out/etc/udev/rules.d/70-ch57x.rules"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
