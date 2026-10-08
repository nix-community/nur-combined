{
  lib,
  callPackage,
  stdenvNoCC,
  makeShellWrapper,
  t3code-unwrapped ? callPackage ./unwrapped.nix { },
  providerPackages ? [ ],
}:

stdenvNoCC.mkDerivation {
  pname = "t3code";
  inherit (t3code-unwrapped) version;

  dontUnpack = true;
  strictDeps = true;

  nativeBuildInputs = [ makeShellWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share"

    sslCertHook='
      if [ -z "''${SSL_CERT_FILE:-}" ]; then
        if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
          export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
        elif [ -f /etc/ssl/certs/ca-bundle.crt ]; then
          export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
        fi
      fi
    '

    makeWrapper ${t3code-unwrapped}/bin/t3 "$out/bin/t3" \
      ${
        lib.optionalString (
          providerPackages != [ ]
        ) "--prefix PATH : ${lib.escapeShellArg (lib.makeBinPath providerPackages)}"
      } \
      --run "$sslCertHook"

    makeWrapper ${t3code-unwrapped.desktop}/bin/t3code-desktop "$out/bin/t3code-desktop" \
      ${
        lib.optionalString (
          providerPackages != [ ]
        ) "--prefix PATH : ${lib.escapeShellArg (lib.makeBinPath providerPackages)}"
      } \
      --unset ELECTRON_RUN_AS_NODE \
      --run "$sslCertHook" \
      --inherit-argv0

    ln -s t3code-desktop "$out/bin/t3code"

    cp -rs ${t3code-unwrapped}/share/. "$out/share/"
    cp -rs ${t3code-unwrapped.desktop}/share/. "$out/share/"

    runHook postInstall
  '';

  passthru = {
    inherit providerPackages;
    inherit (t3code-unwrapped) pnpmDeps resourceMonitor src;
    unwrapped = t3code-unwrapped;
  };

  meta = t3code-unwrapped.meta // {
    description = "Control surface for coding agents";
    mainProgram = "t3code";
  };
}
