{ stdenv, gt-bash-client }:

stdenv.mkDerivation rec {
  pname = "gt-bash-client";
  version = stdenv.lib.substring 0 7 src.rev;
  src = gt-bash-client;

  installPhase = ''
    install -Dm755 translate.sh "$out/bin/gt-bash-client"
  '';

  meta = with stdenv.lib; {
    description = gt-bash-client.description;
    homepage = gt-bash-client.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
