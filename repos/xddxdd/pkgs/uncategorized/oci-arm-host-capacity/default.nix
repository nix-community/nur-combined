{
  fetchFromGitHub,
  lib,
  callPackage,
  nix-update-script,
}:
let
  composer2nixOutput = callPackage ./composer2nix { };
in
composer2nixOutput.overrideAttrs (old: rec {
  pname = "oci-arm-host-capacity";
  version = "0-unstable-2024-08-13";
  src = fetchFromGitHub {
    owner = "hitrov";
    repo = "oci-arm-host-capacity";
    rev = "ea70acaf92bedcf0900a9209bdd8c31106b0df83";
    hash = "sha256-aCo6UDqG+9YVNf3W6pxmx1ml+ApdyyRhtzcVTaPdG/o=";
  };
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
      --replace-fail "\$pathPrefix = ''';" "\$pathPrefix = '$out/';" \
      --replace-fail \
        '$dotenv = Dotenv::createUnsafeImmutable(__DIR__, $envFilename);' \
        '$dotenv = Dotenv::createUnsafeImmutable(dirname($envFilename), basename($envFilename));'
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "This script allows to bypass Oracle Cloud Infrastructure 'Out of host capacity' error immediately when additional OCI capacity will appear in your Home Region / Availability domain";
    homepage = "https://github.com/hitrov/oci-arm-host-capacity";
    license = with lib.licenses; [ mit ];
  };
})
