{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,

  fzf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fzf-tab-completion";
  version = "2025-01-20";

  src = fetchFromGitHub {
    owner = "lincheney";
    repo = "${finalAttrs.pname}";
    hash = "sha256-pgcrRRbZaLoChVPeOvw4jjdDCokUK1ew0Wfy42bXfQo=";
    rev = "4850357beac6f8e37b66bd78ccf90008ea3de40b";
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  runtimeDependencies = [
    fzf
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $src/bash $out/bash
    cp -r $src/node $out/node
    cp -r $src/python $out/python
    cp -r $src/readline $out/readline
    cp -r $src/zsh $out/zsh
    ln -s $out/readline/bin/rl_custom_complete $out/bin/rl_custom_complete

    runHook postInstall
  '';

  meta = {
    description = "Tab completion using fzf";
    homepage = "https://github.com/lincheney/fzf-tab-completion";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ivyfanchiang ];
  };
})
