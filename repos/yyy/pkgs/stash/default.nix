{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  pname = "stash";
  version = "0.24.3";

  src = fetchurl {
    url = "https://github.com/stashapp/stash/releases/download/v${version}/stash-linux";
    sha1 = "7e9aeafb68a360e9f1b19eb2d414d25f5f128bc0";
  };

  unpackPhase = ":";

  installPhase = ''
    install -m755 -D $src $out/bin/stash
    chmod +x $out/bin/stash
  '';

  meta = with lib; {
    description = "An organizer for your porn, written in Go.";
    homepage = "https://github.com/stashapp/stash";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
