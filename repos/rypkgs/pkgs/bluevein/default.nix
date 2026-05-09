{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bluevein";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "meowrch";
    repo = "BlueVein";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qj1qiBhgBxmS5v/Wp9XdSCSSBGKWwpGFQg3/ymOvuR8=";
  };

  cargoHash = "sha256-oqueGWj3Rd+Bjos+vVHfKlNJ86G+1rEb/gXMZjGdxUc=";

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
