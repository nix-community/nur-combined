{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "playonmac";
  version = "4.3.3";

  src = fetchurl {
    url = "https://repository.playonmac.com/PlayOnMac/PlayOnMac_${version}.dmg";
    sha256 = "11gdw7y8f281gpp8vlyrhjaghlaqaxaqq373z7d31rzx7vq9jl3r";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  dontPatchShebangs = true;

  preferLocalBuild = true;

  meta = with lib; {
    description = "GUI for managing Windows programs under macOS";
    homepage = "https://www.playonmac.com/";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
