{ mySources
, stdenvNoCC
, lib
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  inherit (mySources.windows10-icons) pname version src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/Windows10
    cp -r . $out/share/icons/Windows10
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/B00merang-Artwork/Windows-10";
    description = "Windows 10 Light theme for Linux (GTK)";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
})
