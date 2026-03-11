{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  gh,
  jq,
  gawk,
  coreutils,
}:

stdenv.mkDerivation rec {
  pname = "gh-clean-notifications";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "paulbarton90";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mh/ICIlIzYVPwQit8ms0JZYJZ5xFrYNfYz+OMlMTL/8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 gh-clean-notifications $out/bin/gh-clean-notifications

    wrapProgram $out/bin/gh-clean-notifications \
      --prefix PATH : ${lib.makeBinPath [ gh jq gawk coreutils ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "GitHub CLI extension to mark closed/merged notifications as done";
    homepage = "https://github.com/paulbarton90/gh-clean-notifications";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "gh-clean-notifications";
  };
}
