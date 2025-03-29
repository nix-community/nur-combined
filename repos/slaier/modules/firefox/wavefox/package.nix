{ lib, stdenvNoCC, fetchFromGitHub }:
let
  version = "1.8.137";
in
stdenvNoCC.mkDerivation {
  pname = "wavefox";
  inherit version;

  src = fetchFromGitHub ({
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${version}";
    sha256 = "sha256-blDZoxLwP0wX0oFOXH2fBAgyOrSsvwrxs7ScMOfXHTQ=";
  });

  installPhase = ''
    mkdir -p $out
    cp -r ./chrome/* $out
  '';

  meta = with lib; {
    description = "Flexible firefox theme for manual customization.";
    homepage = "https://github.com/QNetITQ/WaveFox";
    license = licenses.mit;
  };
}
