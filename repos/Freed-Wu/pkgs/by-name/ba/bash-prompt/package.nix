{
  mySources,
  lib,
  stdenvNoCC,
  zsh-powerlevel10k,
  wakatime-cli,
  procps,
  git,
  ncurses
}:
stdenvNoCC.mkDerivation {
  inherit (mySources.bash-prompt) pname version src;

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [
    zsh-powerlevel10k
    wakatime-cli
  ];

  installPhase = ''
    install -Dm644 prompt.sh -t $out/share/bash-prompt
  '';
  fixupPhase = ''
    sed -i -e'1,15d' \
      -e'16i. ${zsh-powerlevel10k}/share/zsh-powerlevel10k/gitstatus/gitstatus.prompt.sh' \
      -e's/has_cmd \S\+ && //' \
      -e's|\\wakatime|${wakatime-cli}/bin/wakatime-cli|g' \
      -e's|\\ps|${procps}/bin/ps|g' \
      -e's|\\git|${git}/bin/git|g' \
      -e's|\\tput|${ncurses}/bin/tput|g' \
      $out/share/bash-prompt/prompt.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/bash-prompt";
    description = "A powerlevel10k-like prompt style of bash";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
