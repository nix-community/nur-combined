{ curl, jq, fetchFromGitHub, lib, makeWrapper, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "matrix-notifier";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ambroisie";
    repo = "matrix-notifier";
    rev = "v${version}";
    sha256 = "sha256-MbtxLUVL4bBS66TJTXky/0blR9lFKzLkRccck7Um2Co=";
  };

  phases = [ "installPhase" "fixupPhase" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/${pname} $out/bin/${pname}
    chmod a+x $out/bin/${pname}
  '';

  wrapperPath = lib.makeBinPath [
    curl
    jq
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = ''
      A very simple bash script that can be used to send a message to
      a Matrix room
    '';
    homepage = "https://gitea.belanyi.fr/ambroisie/${pname}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
