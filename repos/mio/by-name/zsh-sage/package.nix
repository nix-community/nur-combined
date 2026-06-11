{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zsh-sage";
  version = "0-unstable-2024-11-20";

  src = fetchFromGitHub {
    owner = "UtsavMandal2022";
    repo = "zsh-sage";
    rev = "3b8afa0ddf5eafc48f92fad45c324c99303debae";
    hash = "sha256-DEzbj+1qbf6CSDQL0sh4Ib7SoaJSvKKBA05KGDTLTeg=";
  };

  strictDeps = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zsh-sage
    cp -r * $out/share/zsh-sage/

    runHook postInstall
  '';

  meta = {
    description = "Intelligent zsh autosuggestions with multi-signal ranking and confidence-colored ghost text";
    homepage = "https://github.com/UtsavMandal2022/zsh-sage";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
