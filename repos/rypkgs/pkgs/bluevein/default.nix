{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bluevein";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "BlueVein";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kzMW1h3wc77V5l8zba8Rt2Oo9+WNXLpuE+EgWhGimEg=";
  };

  cargoHash = "sha256-8hzxuBhtaTDZJU62FY+88l79ns1yz0EPMf8xhktTLQk=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  postInstall = ''
    install -Dm644 systemd/bluevein.service $out/lib/systemd/system/bluevein.service
    substituteInPlace $out/lib/systemd/system/bluevein.service \
      --replace-fail "/usr/bin/bluevein" "$out/bin/bluevein"
  '';

  meta = {
    description = "Bluetooth device synchronization service for dual-boot systems";
    homepage = "https://github.com/meowrch/BlueVein";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "bluevein";
  };
})
