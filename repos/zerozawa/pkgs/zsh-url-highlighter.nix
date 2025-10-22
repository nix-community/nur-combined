{
  fetchFromGitHub,
  stdenv,
  lib,
  zsh,
  ...
}:
stdenv.mkDerivation rec {
  version = "1.0.0";
  pname = "zsh-url-highlighter";
  src = fetchFromGitHub {
    owner = "ascii-soup";
    repo = "zsh-url-highlighter";
    rev = version;
    hash = "sha256-NRlAKHaoXPKrAK+sz09Cyvj8pvnT85Ubh0Hrk4DmuxE=";
  };

  strictDeps = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/zsh-syntax-highlighting/highlighters/
    cp -r url $out/share/zsh-syntax-highlighting/highlighters/
    runHook postInstall
  '';

  meta = with lib; {
    description = "A plugin for zsh-syntax-highlighting that turns URLs green if they respond with a \" good \"** status, and red otherwise. Useful for checking URL typos.";
    homepage = "https://github.com/ascii-soup/zsh-url-highlighter";
    platforms = zsh.meta.platforms;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}
