{
  lib,
  sources,
  callPackage,
  ...
} @ args: let
  composer2nixOutput = callPackage ./composer2nix {};
in
  composer2nixOutput.overrideAttrs (old: rec {
    inherit (sources.oci-arm-host-capacity) pname version src;
    name = "${pname}-${version}";

    postFixup = ''
      substituteInPlace $out/index.php \
        --replace "\$pathPrefix = ''';" "\$pathPrefix = '$out/';" \
        --replace \
          '$dotenv = Dotenv::createUnsafeImmutable(__DIR__, $envFilename);' \
          '$dotenv = Dotenv::createUnsafeImmutable(dirname($envFilename), basename($envFilename));'
    '';

    meta = with lib; {
      description = "This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain.";
      homepage = "https://github.com/hitrov/oci-arm-host-capacity";
      license = with licenses; [mit];
    };
  })
