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
    rev = "8a1f47632e28aceeb9a1de05220e9f88ea7452cf";
    sha256 = "18wl75g82fz42y3z82x95zd3fncx3j3n1d0m92s8p8sb7br1f33f";
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
