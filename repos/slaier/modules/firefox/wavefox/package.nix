{ lib, stdenvNoCC, fetchFromGitHub }:
let
  version = "1.6.117";
in
stdenvNoCC.mkDerivation {
  pname = "wavefox";
  inherit version;

  src = fetchFromGitHub ({
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${version}";
    sha256 = "sha256-Vv9m5I+mraU96h+vyWQMyMyvSFh8l0u+MNxPCCl6qs4=";
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
