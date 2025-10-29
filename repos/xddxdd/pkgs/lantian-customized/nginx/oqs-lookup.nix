{
  openssl-oqs-provider,
  python3,
}:
openssl-oqs-provider.overrideAttrs (old: {
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    ${python3}/bin/python ${./oqs-lookup.py} > $out/oqs_lookup.c

    runHook postInstall
  '';
})
