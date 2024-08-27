{ stdenv
, generated
, lib
}:

stdenv.mkDerivation rec {
  inherit (generated) pname version src;

  dontUnpack = true;

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
