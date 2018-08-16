{ stdenv, wpa_supplicant }:

wpa_supplicant.overrideAttrs (old: {
  name = "eapol_test-${old.version}";

  buildPhase = ''
    runHook preBuild
    echo CONFIG_EAPOL_TEST=y >> .config
    make eapol_test
    runHook postBuild
  '';

  installPhase = ''
    install -D eapol_test $out/bin/eapol_test
  '';

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];
})
