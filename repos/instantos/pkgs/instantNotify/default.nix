{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, instantMenu
, sqlite
}:
stdenv.mkDerivation {

  pname = "instantNotify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantNOTIFY";
    rev = "10217a9a1bfdfb649fed365092d0ce2597e9aad8";
    sha256 = "1fhh5p5g0dd6fpr2fj5bi7bkkbcdxnydgll2x1xfwrlqpd9nb3bk";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ instantMenu sqlite ];

  postPatch = ''
    substituteInPlace install.sh \
      --replace "/usr" "$out" \
      --replace "sudo " ""
    patchShebangs *.sh
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    ./install.sh
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram "$out/bin/instantnotifyctl" \
      --prefix PATH : ${lib.makeBinPath [ sqlite ]}
  '';

  meta = with lib; {
    description = "Notification system for instantOS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantNOTIFY";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
