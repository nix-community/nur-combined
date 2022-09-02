{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "docker-reg-tool";
  version = "2021-02-15";

  src = fetchFromGitHub {
    owner = "byrnedo";
    repo = "docker-reg-tool";
    rev = "23292d234289b1fd114b53786c9e4f9fece3674b";
    hash = "sha256-o2ug69zM1lfG+vgHAcOKxJxDp5UMag8ZbOWU5/tsjG8=";
  };

  installPhase = "install -Dm755 docker_reg_tool -t $out/bin";

  meta = with lib; {
    description = "Docker registry cli tool, primarily for deleting images";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
