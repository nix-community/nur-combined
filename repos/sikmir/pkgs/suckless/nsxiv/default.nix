{ lib, stdenv, fetchFromGitHub, libXft, imlib2, giflib, libexif, libwebp, conf ? null }:

stdenv.mkDerivation rec {
  pname = "nsxiv";
  version = "30";

  src = fetchFromGitHub {
    owner = "nsxiv";
    repo = "nsxiv";
    rev = "v${version}";
    hash = "sha256-swzTdQ6ow1At4bKRORqz6fb0Ej92yU9rlI/OgcinPu4=";
  };

  configFile = lib.optionalString (conf!=null) (builtins.toFile "config.def.h" conf);
  preBuild = lib.optionalString (conf!=null) "cp ${configFile} config.def.h";

  buildInputs = [ libXft imlib2 giflib libexif libwebp ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    install -Dm644 nsxiv.desktop -t $out/share/applications
  '';

  meta = with lib; {
    description = "Neo Simple X Image Viewer";
    inherit (src.meta) homepage;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
