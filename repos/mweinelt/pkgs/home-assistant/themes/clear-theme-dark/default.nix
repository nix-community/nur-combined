{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "clear-theme-dark";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "naofireblade";
    repo = pname;
    rev = "v${version}";
    sha256 = "0jagw2dv1rp5pk854idzcgmlxkybbjv7pc8y3jrbhz8mm081v8nk";
  };

  installPhase = ''
    mkdir $out
    cp themes/clear-dark.yaml $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/naofireblade/clear-theme-dark";
    description = "Dark variant of Clear Theme for Home Assistant";
    license = licenses.mit;
  };
}
