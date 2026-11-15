{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  bash,
  busybox-sandbox-shell,
  coreutils,
  gamescope,
  gawk,
  gnugrep,
  gnused,
  perl,
  jq,
}:

let
  gamescope' = gamescope.overrideAttrs (_: {
    NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
  });
in
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
    gamescope'
    perl
    jq
  ];

  # Steam starts launch-option wrappers with its overlay in LD_PRELOAD. The overlay
  # (gameoverlayrenderer.so) needs libGL.so.1, which Nix-built programs outside
  # Steam's container cannot always resolve, and then every dynamically linked
  # helper of the script (bash, jq, perl, sed, ...) fails to start. Only the game
  # needs the overlay: the entry point moves LD_PRELOAD to SCB_LD_PRELOAD, and the
  # script hands it back to the game command alone. gamescope itself was already
  # started without it upstream.
  postPatch = ''
    substituteInPlace bin/scopebuddy \
      --replace-fail 'LD_PRELOAD_REAL=$LD_PRELOAD' 'LD_PRELOAD_REAL=$SCB_LD_PRELOAD' \
      --replace-fail '# Launch %command% without gamescope' \
        'if [ -n "''${SCB_LD_PRELOAD+set}" ]; then export LD_PRELOAD="$SCB_LD_PRELOAD"; fi # Launch %command% without gamescope, with the LD_PRELOAD Steam passed in'
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/scopebuddy $out/libexec/scopebuddy/scopebuddy
    wrapProgram $out/libexec/scopebuddy/scopebuddy \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          gamescope'
          perl
          jq
          gawk
          gnugrep
          gnused
          coreutils
        ]
      } \
      --set SCB_AUTO_RES "1" \
      --set SCB_AUTO_HDR "1" \
      --set SCB_AUTO_VRR "1"

    # Statically linked entry point: the dynamic loader ignores LD_PRELOAD for it,
    # so a preloaded library with unresolvable dependencies cannot stop it.
    mkdir -p $out/bin
    cat > $out/bin/scopebuddy <<EOF
    #!${busybox-sandbox-shell}/bin/busybox sh
    if [ -n "\''${LD_PRELOAD+set}" ]; then
      export SCB_LD_PRELOAD="\$LD_PRELOAD"
      unset LD_PRELOAD
    fi
    exec $out/libexec/scopebuddy/scopebuddy "\$@"
    EOF
    chmod +x $out/bin/scopebuddy
    ln -s scopebuddy $out/bin/scb
    runHook postInstall
  '';

  meta = with lib; {
    description = "A manager script to make gamescope easier to use on desktop";
    homepage = "https://github.com/OpenGamingCollective/ScopeBuddy";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "scopebuddy";
  };
})
