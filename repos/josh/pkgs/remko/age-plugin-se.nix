# Upstream to NixOS/nixpkgs
# - Needs to build from source rather than install binaries.
#   - Blocked on NixOS/nixpkgs supporting Swift 6.0
#
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  runCommand,
  testers,
  age,
}:
let
  version = "0.1.4";
  sources = {
    "aarch64-darwin" = fetchurl {
      url = "https://github.com/remko/age-plugin-se/releases/download/v0.1.4/age-plugin-se-v0.1.4-macos.zip";
      sha256 = "0i1yd5zpyw1ziirp4cr5jrlhw6xldvjrpxk9lsiay8153pdp0ksh";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/remko/age-plugin-se/releases/download/v0.1.4/age-plugin-se-v0.1.4-aarch64-linux.tgz";
      sha256 = "11hyqakcp3jvr092z61b9sv1bpn088f68bxmigja7w4mb1bar6j5";
    };
    "x86_64-linux" = fetchurl {
      url = "https://github.com/remko/age-plugin-se/releases/download/v0.1.4/age-plugin-se-v0.1.4-x86_64-linux.tgz";
      sha256 = "1lw1iycri4v0xgpsih83abl3gmy6lmcz83m57vi0jjrgkfl5q57x";
    };
  };
  useZip = stdenvNoCC.hostPlatform.system == "aarch64-darwin";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "age-plugin-se";
  inherit version;
  src = sources.${stdenvNoCC.hostPlatform.system};

  nativeBuildInputs = [
    (lib.optional useZip unzip)
  ];
  sourceRoot = if useZip then "." else null;

  installPhase = ''
    if [ -f age-plugin-se ]; then
      mkdir -p $out/bin
      cp age-plugin-se $out/bin/
    elif [ -f usr/bin/age-plugin-se ]; then
      mkdir -p $out/bin
      cp usr/bin/age-plugin-se $out/bin/
    else
      echo "age-plugin-se not found"
      exit 1
    fi
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };

    help =
      runCommand "test-age-plugin-se-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          age-plugin-se --help
          touch $out
        '';

    encrypt =
      runCommand "test-age-plugin-se-encrypt"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [
            age
            finalAttrs.finalPackage
          ];
        }
        ''
          echo "Hello World" | age --encrypt \
            --recipient "age1se1qgg72x2qfk9wg3wh0qg9u0v7l5dkq4jx69fv80p6wdus3ftg6flwg5dz2dp" \
            --armor
          touch $out
        '';
  };

  meta = with lib; {
    description = "Age plugin for Apple's Secure Enclave";
    homepage = "https://github.com/remko/age-plugin-se";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "age-plugin-se";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
