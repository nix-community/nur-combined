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

stdenv.mkDerivation (finalAttrs: {
  pname = "scopebuddy";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "OpenGamingCollective";
    repo = "ScopeBuddy";
    tag = finalAttrs.version;
    hash = "sha256-Z4KE6Qs5dcNdoEra1sx69I8EsxztAeVNGgO0ltYz7r0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    (gamescope.overrideAttrs (_: {
      NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
    }))
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
          (gamescope.overrideAttrs (_: {
            NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
          }))
          perl
          jq
        ]
      } \
      --set SCB_AUTO_RES "1" \
      --set SCB_AUTO_HDR "1" \
      --set SCB_AUTO_VRR "1"
  '';

  meta = with lib; {
    description = "A manager script to make gamescope easier to use on desktop";
    homepage = "https://github.com/OpenGamingCollective/ScopeBuddy";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "scopebuddy";
  };
})
