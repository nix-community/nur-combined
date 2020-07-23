{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "weather-card-chart";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "Yevgenium";
    repo = "lovelace-weather-card-chart";
    rev = version;
    sha256 = "0xcasbrzjfihm4dq099yiy52gd8zn9s77dsfrw3ng3vinkg8gxfs";
  };

  installPhase = ''
    mkdir $out
    cp -v weather-card-chart.js $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/Yevgenium/lovelace-weather-card-chart";
    description = "Custom weather card with charts";
    license = licenses.mit;
  };
}
