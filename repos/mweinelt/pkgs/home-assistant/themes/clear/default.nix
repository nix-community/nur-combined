{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "clear";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "naofireblade";
    repo = "clear-theme";
    rev = "v${version}";
    sha256 = "0nhprp6bs0i17gjvlmrl86b6c8x7r2ia2hhljd7j8r3sp2nhzrbl";
  };

  installPhase = ''
    mkdir $out
    cp themes/clear.yaml $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/naofireblade/clear-theme-dark";
    description = "Clear Theme for Home Assistant";
    license = licenses.mit;
  };
}
