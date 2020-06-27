{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "gt-bash-client";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.gt-bash-client;

  installPhase = ''
    install -Dm755 translate.sh "$out/bin/gt-bash-client"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
