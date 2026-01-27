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
  version = "unstable-2024-01-20";

  src = fetchFromGitHub {
    owner = "HikariKnight";
    repo = "ScopeBuddy";
    rev = "51cbc9a9daef05ff8015dc848f55cb1e0828a2ab";
    hash = "sha256-ge89pCbisCF2ImxkUsNHJPVLO6kK4CsyCnYxZDNx75Y=";
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
    homepage = "https://github.com/HikariKnight/ScopeBuddy";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "scopebuddy";
  };
}
