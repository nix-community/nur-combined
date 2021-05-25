{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "filebrowser";
  version = "2.15.0";

  src = fetchurl {
    url =
      "https://github.com/filebrowser/filebrowser/releases/download/v${version}/linux-amd64-filebrowser.tar.gz";
    sha256 = "sha256-pIcbst3VIPMhnoRfaheyrd8dFAZMccug04GID2wZ0Gc=";
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 filebrowser $out/bin/filebrowser
  '';

  meta = with lib; {
    description = "Provides an HTTP file managing interface";
    homepage = "https://filebrowser.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ plabadens ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
