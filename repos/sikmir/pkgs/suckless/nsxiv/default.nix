{ lib, stdenv, fetchFromGitHub, libXft, imlib2, giflib, libexif, libwebp, conf ? null }:

stdenv.mkDerivation rec {
  pname = "nsxiv";
  version = "29";

  src = fetchFromGitHub {
    owner = "nsxiv";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-JUF2cF6QeAXk6G76uMu3reaMgxp2RcqHDbamkNufwqE=";
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
