{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  pname = "stash";
  version = "0.22.1";

  src = fetchurl {
    url = "https://github.com/stashapp/stash/releases/download/v${version}/stash-linux";
    sha256 = "e46bfb717fb415e8c6def824be1ad3d4f33a0f6eb2114afc7e985c3745d4e44c";
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
