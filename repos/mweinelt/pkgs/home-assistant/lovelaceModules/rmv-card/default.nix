{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "rmv-card";
  version = "unstable-2020-07-08";

  src = fetchFromGitHub {
    owner = "custom-cards";
    repo = "rmv-card";
    rev = "fcfae8e370b33216e0c257f9bc23cb9c10097d0e";
    sha256 = "0ds82rrfw84ykbg42srihrvg53apfhfybl0z2d0g245bx0iamnq0";
  };

  installPhase = ''
    mkdir $out
    cp -v rmv-card.js $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/cgtobi/rmv-card";
    description = "Custom card for the RMV component";
    license = licenses.mit;  # assume MIT since the api bindings are MIT as well; https://github.com/cgtobi/rmv-card/issues/1
  };
}
