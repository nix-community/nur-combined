{ stdenv
, lib
, fetchurl
, appimageTools
, wrapQtAppsHook
}:

appimageTools.wrapType2 rec {
  name = "glaxnimate";
  pname = "glaxnimate";
  version = "0.5.1";

  src = fetchurl {
    url = "https://gitlab.com/api/v4/projects/19921167/jobs/artifacts/release/raw/build/${pname}-x86_64.AppImage?job=linux%3Aappimage";
    name = "glaxnimate-patchwork";
    sha256 = "08blixqjnz0alg1vnazp6jk8rrg9wv8c70jwcfnnnylq9xnyzr4n";
  };

  meta = with lib; {
    description = "Simple and fast vector graphics animation program";
    longDescription = ''Glaxnimate is a 2D vector drawing and animation program
that is now integrated and bundled
with Shotcut and Kdenlive.
'';
    homepage = https://glaxnimate.mattbas.org/;
    changelog = "https://gitlab.com/mattbas/glaxnimate/-/releases";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
