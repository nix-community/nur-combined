{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "docker-reg-tool";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.docker-reg-tool;

  installPhase = ''
    install -Dm755 docker_reg_tool "$out/bin/docker_reg_tool"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
