{ stdenv
, open-in-mpv
, zip
}:
stdenv.mkDerivation {
  pname = "open-in-mpv-firefox";
  inherit (open-in-mpv) version src;

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall
    install build/firefox.zip $out
    runHook postInstall
  '';

  makeFlags = [ "build/firefox.zip" ];

  passthru.extid = "{d66c8515-1e0d-408f-82ee-2682f2362726}";
}
