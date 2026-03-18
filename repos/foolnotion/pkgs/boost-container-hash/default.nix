{ lib, stdenv, fetchFromGitHub, boostConfig 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost-container-hash";
  version = "1.90.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "container_hash";
    rev = "boost-${version}";
    sha256 = "sha256-Yu3Qc7yRFkusfnS107Rrs+yXFcBQuNhfZ9lAAMsHbLA=";
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
    description = "Boost container hash support headers";
    homepage = "https://github.com/boostorg/container_hash";
    license = licenses.boost;
    platforms = platforms.all;
  };
}