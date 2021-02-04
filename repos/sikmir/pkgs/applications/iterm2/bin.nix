{ lib, stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "iterm2-bin";
  version = "3.3.12";

  src = fetchurl {
    url = "https://iterm2.com/downloads/stable/iTerm2-${lib.replaceStrings [ "." ] [ "_" ] version}.zip";
    sha256 = "0rw165p9iypc11pr0mmwd1z4dvg0f3is2p8bv2sk30wyd4hba4b8";
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r iTerm.app $out/Applications
    /usr/bin/defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "A replacement for Terminal and the successor to iTerm";
    homepage = "https://iterm2.com/";
    license = licenses.gpl2;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
