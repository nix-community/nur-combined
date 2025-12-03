{
  pkgs,  # for outer `open-in-mpv`
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "open-in-mpv-firefox";
  inherit (pkgs.open-in-mpv) version src;

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  installPhase = ''
    runHook preInstall
    mkdir $out
    install build/firefox.zip $out/$extid.xpi
    runHook postInstall
  '';

  makeFlags = [
    "BUILD_DIR=build"
    "build/firefox.zip"
  ];

  extid = "{d66c8515-1e0d-408f-82ee-2682f2362726}";
}
