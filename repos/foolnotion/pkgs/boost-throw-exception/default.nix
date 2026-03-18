{ lib, stdenv, fetchFromGitHub, boostAssert, boostConfig, boostCore 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-throw-exception";
  version = "1.90.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "throw_exception";
    rev = "boost-${version}";
    sha256 = "sha256-kqpcApJQv9vbhRF0YyVuHJtv6J+hvlve9KuzWHyxLT8=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/boost
    cp -r include/boost/* $out/include/boost/
    runHook postInstall
  '';

  propagatedBuildInputs = [ boostAssert boostConfig boostCore ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Boost exception throwing support headers";
    homepage = "https://github.com/boostorg/throw_exception";
    license = licenses.boost;
    platforms = platforms.all;
  };
}