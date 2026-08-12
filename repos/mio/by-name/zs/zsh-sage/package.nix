{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zsh-sage";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "UtsavMandal2022";
    repo = "zsh-sage";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-LUnPM071nD6Uam7oPLLk5ZMIy4wr+hj1WM4YuIOPAMs=";
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
