{ lib
, stdenv
, fetchFromGitHub
, boostAssert
, boostConfig
, boostContainerHash
, boostCore
, boostHana
, boostThrowException
, boostTypeIndex
}:

stdenv.mkDerivation rec {
  pname = "boost-parser";
  version = "1.92.0.beta1";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "parser";
    rev = "boost-${version}";
    sha256 = "sha256-Q8wG2XwdhJBTu4lQf/a80T+/mXZ/840Ea+lcYMMd7Xw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost

    cp -r include/boost/parser $out/include/boost/

    chmod -R u+w $out/include/boost
    cp -rn ${boostAssert}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostHana}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostTypeIndex}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostConfig}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostCore}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostContainerHash}/include/boost/* $out/include/boost/
    chmod -R u+w $out/include/boost
    cp -rn ${boostThrowException}/include/boost/* $out/include/boost/

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Parser combinator library for C++";
    homepage = "https://github.com/boostorg/parser";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
