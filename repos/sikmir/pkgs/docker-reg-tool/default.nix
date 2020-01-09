{ stdenv, docker-reg-tool }:

stdenv.mkDerivation rec {
  pname = "docker-reg-tool";
  version = stdenv.lib.substring 0 7 src.rev;
  src = docker-reg-tool;

  installPhase = ''
    install -Dm755 docker_reg_tool "$out/bin/docker_reg_tool"
  '';

  meta = with stdenv.lib; {
    description = docker-reg-tool.description;
    homepage = docker-reg-tool.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
