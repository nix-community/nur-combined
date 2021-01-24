{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "docker-reg-tool";
  version = stdenv.lib.substring 0 10 sources.docker-reg-tool.date;

  src = sources.docker-reg-tool;

  installPhase = "install -Dm755 docker_reg_tool -t $out/bin";

  meta = with stdenv.lib; {
    inherit (sources.docker-reg-tool) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
