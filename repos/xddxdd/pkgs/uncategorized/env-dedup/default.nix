{
  stdenv,
  sources,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (sources.env-dedup) pname version src;

  buildPhase = ''
    runHook preBuild

    cc -shared -fPIC -O3 -D_GNU_SOURCE -o libenv_dedup_dynamic_optimised.so env_dedup_dynamic_optimised.c -ldl

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    install -Dm755 libenv_dedup_dynamic_optimised.so $out/lib/libenv_dedup.so

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Deduplicate the environment variables values";
    homepage = "https://github.com/alexjp/env-dedup";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
