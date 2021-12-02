{ lib, stdenv, fetchFromGitHub, libXft, imlib2, giflib, libexif, libwebp, conf ? null }:

stdenv.mkDerivation rec {
  pname = "nsxiv";
  version = "2021-12-01";

  src = fetchFromGitHub {
    owner = "nsxiv";
    repo = pname;
    rev = "79b8fefcc45d6279c28505ab3d07f539fb9726ff";
    hash = "sha256-ZimwfNiopkka3htHkQRcSuVeU/YM36HcU8nokGHc7nM=";
  };

  configFile = lib.optionalString (conf!=null) (builtins.toFile "config.def.h" conf);
  preBuild = lib.optionalString (conf!=null) "cp ${configFile} config.def.h";

  buildInputs = [ libXft imlib2 giflib libexif libwebp ];

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
