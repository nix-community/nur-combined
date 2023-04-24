{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mediawiki-oredict";
  version = "3.3.5";

  src = fetchFromGitHub {
    owner = "FTB-Gamepedia";
    repo = "OreDict";
    rev = "${version}";
    sha256 = "sha256-pSBGZoZ9azZSOrg5BNd214zH9uvITkNA7BuN2RcKegk=";
  };

  postInstall = ''

  mkdir -p $out/share/mediawiki/extensions/${pname}

  cp -r $src/* $out/share/mediawiki/extensions/${pname}
  '';

  meta = with lib; {
    description = "A MediaWiki extension which mimics Minecraft's ore dictionary system";
    homepage = "https://github.com/FTB-Gamepedia/OreDict";
    changelog = "https://github.com/FTB-Gamepedia/OreDict/blob/master/CHANGELOG.md";
    license = licenses.mit;
  };
}
