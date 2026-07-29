{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zsh-sage";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "UtsavMandal2022";
    repo = "zsh-sage";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-Pa3GLP29hF6rWsLsJBAlVRL8RvdvzZQQl8viWCI2QUc=";
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
