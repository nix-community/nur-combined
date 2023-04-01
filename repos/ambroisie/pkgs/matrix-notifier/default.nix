{ lib, curl, jq, fetchFromGitHub, makeWrapper, pandoc, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "matrix-notifier";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ambroisie";
    repo = "matrix-notifier";
    rev = "v${version}";
    hash = "sha256-NE9RO0ep2ibrT9EUPGTnUE3ofdNTCHwelxnX9tCflg0=";
  };

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
    pandoc
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
    homepage = "https://git.belanyi.fr/ambroisie/${pname}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
