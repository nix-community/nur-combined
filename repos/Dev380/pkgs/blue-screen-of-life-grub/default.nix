{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "blue-screen-of-life";
  version = "1.0-unstable-2024-11-14";

  src = fetchFromGitHub {
    owner = "harishnkr";
    repo = "bsol";
    rev = "8f39f66967e2391b11ee554578f0b821070ec72a";
    hash = "sha256-UD5crwJdqnKVnxTN2vHIukJnQuzxmkko3E5wb8Xg6gs=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r bsol/* "$out/"

    runHook postInstall
  '';
}
