{ git, stdenvNoCC }: stdenvNoCC.mkDerivation {
  pname = "git-completion.zsh";
  inherit (git) version src;

  dontConfigure = true;

  inherit git;
  buildPhase = ''
    runHook preBuild

    sed -i contrib/completion/git-completion.zsh \
      -e "s|/usr/share/bash-completion/completions|$git/share/bash-completion/completions|"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm0755 contrib/completion/git-completion.zsh $out/share/zsh/site-functions/_git

    runHook postInstall
  '';
}
