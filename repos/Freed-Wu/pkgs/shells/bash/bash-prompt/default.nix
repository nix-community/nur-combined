{
  lib,
  stdenvNoCC,
  zsh-powerlevel10k,
  fetchFromGitHub,
  wakatime,
}:
stdenvNoCC.mkDerivation rec {
  name = "bash-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "f6d81a940afb00fc19fa0c87b6ce2bfe623aabb8";
    hash = "sha256-Yu+eeDBbTkp3bPXKlGGz3K/PbZCsGRgd9XEUUvkggTU=";
  };

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [
    zsh-powerlevel10k
    wakatime
  ];

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
