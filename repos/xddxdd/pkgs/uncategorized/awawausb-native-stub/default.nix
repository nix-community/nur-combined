{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "awawausb-native-stub";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "ArcaneNibble";
    repo = "awawausb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9lkQtItaU5xVMsStB2RJt+JP8TTdP4A8xMD0dIfeJH8=";
  };
  cargoHash = "sha256-By8H8NcxB8cync1MZ+IggKUIb5+XtMIdK9zLcf7uQJg=";

  cargoRoot = "native-stub";
  buildAndTestSubdir = "native-stub";

  postInstall = ''
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    cat > $out/lib/mozilla/native-messaging-hosts/awawausb_native_stub.json <<EOF
    {
      "name": "awawausb_native_stub",
      "description": "Allows WebUSB extension to access USB devices",
      "path": "$out/bin/awawausb-native-stub",
      "type": "stdio",
      "allowed_extensions": ["awawausb@arcanenibble.com"]
    }
    EOF
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/ArcaneNibble/awawausb/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/ArcaneNibble/awawausb";
    description = "Native messaging stub for the awawausb WebUSB Firefox extension";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "awawausb-native-stub";
    platforms = lib.platforms.linux;
  };
})
