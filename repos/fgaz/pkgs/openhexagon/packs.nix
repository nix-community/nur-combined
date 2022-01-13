{ lib, stdenv, fetchurl, fetchFromGitHub, unzip }:

{
  faith = fetchFromGitHub {
    name = "openhexagon-faith";
    owner = "hithroc";
    repo = "open-hexagon-faith";
    rev = "d9d1baab868cc5dabc53d84a4cff9e5fef458387";
    sha256 = "1ybjiz0ihafrxif2xbgvwhfiz36rhl6j5hf7ks67pah0pfqls095";
    meta = with lib; {
      homepage = https://github.com/hithroc/open-hexagon-faith;
      description = "Spontaneous level pack for Open Hexagon";
      license = licenses.bsd3;
      maintainers = with maintainers; [ fgaz ];
    };
  };
  tuxo = stdenv.mkDerivation {
    name = "openhexagon-tuxopack";
    src = fetchurl {
      url = "https://files.gamebanana.com/mods/tuxo_pack_update1.zip";
      sha256 = "0b1kjqpq4y9y8vp5j0a999q4qkyz9vsc336cl5yvbl8zqgp4c3p8";
    };
    nativeBuildInputs = [ unzip ];
    dontBuild = true;
    installPhase = "cp -r . $out";
    meta = with lib; {
      homepage = https://gamebanana.com/gamefiles/4312;
      downloadPage = https://gamebanana.com/gamefiles/download/4312;
      description = "Tuxo's level pack with 8 levels";
      license = "cc-by-nc-nd-40"; # TODO add license in nixpkgs
      maintainers = with maintainers; [ fgaz ];
    };
  };
}

