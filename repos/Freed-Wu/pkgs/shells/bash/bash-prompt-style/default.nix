{ lib
, stdenv
, zsh-powerlevel10k
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "bash-prompt-style";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "ad2ff4730809a203bfd8f62cc766f5ae825bc9e7";
    hash = "sha256-Dvm7nJ6UIflOmi2asD5P1P91Qbmgh2sYfQJpkkFk2qQ=";
  };

  buildInputs = [ zsh-powerlevel10k ];

  installPhase = ''
    install -Dm644 prompt-style.sh -t $out/share/bash-prompt-style
  '';
  fixupPhase = ''
    sed -i '1,15d' $out/share/bash-prompt-style/prompt-style.sh
    sed -i '1i. ${zsh-powerlevel10k.out}/share/zsh-powerlevel10k/gitstatus/gitstatus.prompt.sh' $out/share/bash-prompt-style/prompt-style.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/manpager";
    description = "A powerlevel10k-like prompt style of bash";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
