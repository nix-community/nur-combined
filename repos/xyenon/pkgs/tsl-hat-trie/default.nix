{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tsl-hat-trie";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "Tessil";
    repo = "hat-trie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5L3qSlwYc2G60GPFrEz06eAWdUcdBQTVBLLOf1sLP0c=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include
    cp -r include/tsl $out/include/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C++ implementation of a fast and memory efficient HAT-trie";
    homepage = "https://github.com/Tessil/hat-trie";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    platforms = platforms.all;
  };
})
