{ lib
, stdenv
, zsh-powerlevel10k
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "bash-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "5efa0f4c283579bb5bd35d568ba338729b764cc8";
    hash = "sha256-aL3O35Hq8Jr0hMM3da95hxTalPmxIExajbf22LsuUC0=";
  };

  buildInputs = [ zsh-powerlevel10k ];

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
