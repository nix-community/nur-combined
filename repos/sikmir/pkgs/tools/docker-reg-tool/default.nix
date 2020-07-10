{ stdenv, sources }:
let
  pname = "docker-reg-tool";
  date = stdenv.lib.substring 0 10 sources.docker-reg-tool.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.docker-reg-tool;

  installPhase = ''
    install -Dm755 docker_reg_tool -t $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (sources.docker-reg-tool) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
