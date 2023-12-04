{ lib
, stdenv
, zsh-powerlevel10k
, fetchFromGitHub
, wakatime
}:
stdenv.mkDerivation rec {
  name = "bash-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "d472bce2ca0593a45c99c7362b4d587a016b5d51";
    hash = "sha256-M+o6N9+KW6hy+0SY5hH3qcJ8Q4Lcw73wrrlpi9FfQ54=";
  };

  buildInputs = [ zsh-powerlevel10k wakatime ];

  installPhase = ''
    install -Dm644 prompt.sh -t $out/share/bash-prompt
  '';
  fixupPhase = ''
    sed -i '1,15d' $out/share/bash-prompt/prompt.sh
    sed -i '1i. ${zsh-powerlevel10k.out}/share/zsh-powerlevel10k/gitstatus/gitstatus.prompt.sh' $out/share/bash-prompt/prompt.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/bash-prompt";
    description = "A powerlevel10k-like prompt style of bash";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
