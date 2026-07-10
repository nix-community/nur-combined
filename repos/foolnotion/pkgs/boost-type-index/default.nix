{ lib
, stdenv
, fetchFromGitHub
, boostConfig
, boostContainerHash
, boostCore
, boostThrowException

, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-type-index";
  version = "1.91.0.beta1";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "type_index";
    rev = "boost-${version}";
    sha256 = "sha256-4EJhzd6aTLhk1TzwG6TgBYNF/eFvvOO//eWh2+kgZnk=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  propagatedBuildInputs = [
    boostConfig
    boostContainerHash
    boostCore
    boostThrowException
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Boost runtime and compile-time type index headers";
    homepage = "https://github.com/boostorg/type_index";
    license = licenses.boost;
    platforms = platforms.all;
  };
}