{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  callPackage,
}:
lib.makeOverridable (
  {
    eddsaSupport ? false,
  }:
  let
    tinycbor = callPackage ./tinycbor.nix { };
    mbedtls = callPackage ./mbedtls.nix { } { inherit eddsaSupport; };
  in
  stdenvNoCC.mkDerivation {
    pname = "pico-keys-sdk";
    version = "unstable-2025-04-06";

    src = fetchFromGitHub {
      owner = "polhenarejos";
      repo = "pico-keys-sdk";
      rev = "580b0acffa8e685caee4508fb656b78247064248";
      hash = "sha256-uzOeX5EwZ0iQ53zs6VU+PukyTWcEG4HBqWPF8JqDG74=";
    };

    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/pico-keys-sdk
      cp -r . $out/share/pico-keys-sdk
      cp -r "${tinycbor}/share/tinycbor" $out/share/pico-keys-sdk
      cp -r "${mbedtls}/share/mbedtls" $out/share/pico-keys-sdk
      runHook postInstall
    '';

    meta = {
      description = "Core functionalities to transform Raspberry Pico into a CCID device";
      homepage = "https://github.com/polhenarejos/pico-keys-sdk";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ vizid ];
    };
  }
)
