{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bluevein";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "BlueVein";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0d+wK5XWFoQKBJxgqUUL3TkMBHeAs3HExJmFquXCAJw=";
  };

  cargoHash = "sha256-qoHyi08hoPXxZaCe/yg5ESUI6gfr80iQT9PDB0v0zBg=";

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
