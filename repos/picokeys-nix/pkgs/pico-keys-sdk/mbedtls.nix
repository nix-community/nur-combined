{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
lib.makeOverridable (
  {
    eddsaSupport ? true,
  }:
  stdenvNoCC.mkDerivation {
    pname = "mbedtls";
    version = if eddsaSupport then "unstable-2025-03-24" else "3.6.3";

    src = fetchFromGitHub {
      owner = if eddsaSupport then "polhenarejos" else "Mbed-TLS";
      repo = "mbedtls";
      rev = if eddsaSupport then "6320af56726247352af5a003ae77f465f5b4f1c7" else "v3.6.3";
      hash =
        if eddsaSupport then
          "sha256-4eiqm1+0bT4pEbmuvNJABRcCYHWYw8yLQwW0On7RU7c="
        else
          "sha256-FJuezgVTxzLRz0Jzk2XnSnpO5sTc8q6QgzkCwlqQ+EU=";
      fetchSubmodules = true;
    };

    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/mbedtls
      cp -r . $out/share/mbedtls
      runHook postInstall
    '';

    meta = {
      description = "An open source, portable, easy to use, readable and flexible TLS library, and reference implementation of the PSA Cryptography API. Releases are on a varying cadence, typically around 3 - 6 months between releases";
      homepage = "https://github.com/Mbed-TLS/mbedtls";
      license = with lib.licenses; [
        gpl2Plus
        asl20
      ];
      maintainers = with lib.maintainers; [ vizid ];
    };
  }
)
