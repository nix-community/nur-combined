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
  version = "1.7.0";
  meta = {
    description = "Command-line tool for programming ch57x keyboard";
    homepage = "https://github.com/kriomant/ch57x-keyboard-tool";
    license = lib.licenses.mit;
  };

  passthru.updateScript = nix-update-script { };

  src = fetchCrate {
    inherit (ch57x-keyboard-tool) pname version;
    sha256 = "sha256-IBrimdhosz8a5oQd8hfVXp7VTjVCXwn6vvPjHQ9/43I=";
  };

  cargoHash = "sha256-ojQ9tiN9H7xYFdunYTjj93QX7d/ZJDtrtqg56B27ysU=";

  postInstall = ''
    install -D ${rules} "$out/etc/udev/rules.d/70-ch57x.rules"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
