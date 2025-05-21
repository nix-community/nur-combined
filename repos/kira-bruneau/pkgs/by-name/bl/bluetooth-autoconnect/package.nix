{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  wrapGAppsHook4,
  gobject-introspection,
  python3,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bluetooth-autoconnect";
  version = "1.3";
  format = "other";

  src = fetchFromGitHub {
    owner = "jrouleau";
    repo = "bluetooth-autoconnect";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-qfU7fNPNRQxIxxfKZkGAM6Wd3NMuNI+8DqeUW+LYRUw=";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    gobject-introspection
    (python3.withPackages (
      ps: with ps; [
        dbus-python
        pygobject3
      ]
    ))
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bluetooth-autoconnect -t "$out/bin"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux command line tool to automatically connect to all paired and trusted bluetooth devices";
    homepage = "https://github.com/jrouleau/bluetooth-autoconnect";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "bluetooth-autoconnect";
  };
})
