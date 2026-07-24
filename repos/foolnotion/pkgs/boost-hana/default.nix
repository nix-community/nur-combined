{ lib, stdenv, fetchFromGitHub, boostConfig 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-hana";
  version = "1.92.0.beta1";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "hana";
    rev = "boost-${version}";
    sha256 = "sha256-lFaH6qPEDtYEKAjZhFyvqtfQR3GENkE/15zkGNgAy7A=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  propagatedBuildInputs = [ boostConfig ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Header-only library for C++ metaprogramming suited for computations on both types and values";
    homepage = "https://github.com/boostorg/hana";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
