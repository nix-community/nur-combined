{
  lib,
  openssl-oqs-provider,
  python3,
}:
openssl-oqs-provider.overrideAttrs (old: {
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    ${lib.getExe python3} ${./oqs-lookup.py} > $out/oqs_lookup.c

    runHook postInstall
  '';
})
