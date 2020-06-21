{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "rmv-card";
  version = "unstable-2020-05-25";

  src = fetchFromGitHub {
    owner = "cgtobi";
    repo = "rmv-card";
    rev = "0e2bb1874fed596a8bf7871dcfcaf775c505e62e";
    sha256 = "01cip9rvhb5hq960lx2ipxjh7hdj5jyl4b0vbq0588j1dz3bnrq2";
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
