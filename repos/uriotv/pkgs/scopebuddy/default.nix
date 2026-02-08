{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  bash,
  gamescope,
  perl,
  jq,
}:

stdenv.mkDerivation {
  pname = "scopebuddy";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "OpenGamingCollective";
    repo = "ScopeBuddy";
    rev = "1.4.0";
    hash = "sha256-1n1lZidbtDV9Lm8QKd1s35bOS6Uh8sI3KtBJZ+FwdxQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    gamescope
    perl
    jq
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/scopebuddy $out/bin/scopebuddy
    chmod +x $out/bin/scopebuddy
    ln -s $out/bin/scopebuddy $out/bin/scb
    wrapProgram $out/bin/scopebuddy \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          gamescope
          perl
          jq
        ]
      } \
      --set SCB_AUTO_RES "1" \
      --set SCB_AUTO_HDR "1" \
      --set SCB_AUTO_VRR "1" \
      --add-flags "--force-composition"
  '';

  meta = with lib; {
    description = "A manager script to make gamescope easier to use on desktop";
    homepage = "https://github.com/OpenGamingCollective/ScopeBuddy";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "scopebuddy";
  };
}
