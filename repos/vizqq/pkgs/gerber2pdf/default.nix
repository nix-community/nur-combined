{
  lib,
  stdenv,
  source,
}:

stdenv.mkDerivation {
  inherit (source) pname src;

  version = lib.replaceStrings [ "Version_" ] [ "" ] source.version;

  installPhase = "install -D Engine/bin/Gerber2pdf $out/bin/gerber2pdf";

  meta = {
    description = "Gerber to PDF converter";
    homepage = "https://github.com/jpt13653903/Gerber2PDF";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "gerber2pdf";
    platforms = lib.platforms.linux;
  };
}
