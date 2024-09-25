{
  lib,
  sources,
  callPackage,
  ...
}:
let
  composer2nixOutput = callPackage ./composer2nix { };
in
composer2nixOutput.overrideAttrs (old: rec {
  inherit (sources.oci-arm-host-capacity) pname version src;
  name = "${pname}-${version}";

  unpackPhase = ''
    runHook preUnpack
    ${old.unpackPhase or ""}
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    ${old.buildPhase or ""}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${old.installPhase or ""}
  '';
  # runHook postInstall is already present in installPhase

  postFixup = ''
    substituteInPlace $out/index.php \
      --replace "\$pathPrefix = ''';" "\$pathPrefix = '$out/';" \
      --replace \
        '$dotenv = Dotenv::createUnsafeImmutable(__DIR__, $envFilename);' \
        '$dotenv = Dotenv::createUnsafeImmutable(dirname($envFilename), basename($envFilename));'
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain.";
    homepage = "https://github.com/hitrov/oci-arm-host-capacity";
    license = with licenses; [ mit ];
  };
})
