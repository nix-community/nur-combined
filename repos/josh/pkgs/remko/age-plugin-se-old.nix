{
  lib,
  stdenvNoCC,
  fetchzip,
  age-plugin-se,
  runCommand,
  testers,
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    inherit (finalAttrs) version;
    sources = {
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/remko/age-plugin-se/releases/download/v${version}/age-plugin-se-v${version}-macos.zip";
        sha256 = "sha256-xJ4KHEpDFNGYPUsMlxoVPZe9t8raX0Ohf8jZI+z97y0=";
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/remko/age-plugin-se/releases/download/v${version}/age-plugin-se-v${version}-aarch64-linux.tgz";
        sha256 = "sha256-T3tiH2vig+w7PMgMioHCyOAQN5T0TXlUnYgRKqe/aV4=";
      };
      "x86_64-linux" = fetchzip {
        url = "https://github.com/remko/age-plugin-se/releases/download/v${version}/age-plugin-se-v${version}-x86_64-linux.tgz";
        sha256 = "sha256-hBbB5xNEOCZcS+MXG9xJlNNW4oIvchsyYpezqR1SWJs=";
      };
    };
  in
  {
    pname = "age-plugin-se";
    version = "0.1.4";

    src = sources.${stdenvNoCC.targetPlatform.system};

    installPhase = ''
      if [ -d $src/usr/bin ]; then
        install -Dm755 $src/usr/bin/age-plugin-se $out/bin/age-plugin-se
      elif [ -f $src/age-plugin-se ]; then
        install -Dm755 $src/age-plugin-se $out/bin/age-plugin-se
      else
        echo "error: age-plugin-se not found in $src" >&2
        exit 1
      fi
    '';

    passthru.tests = {
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
        version = "v${version}";
      };

      help = runCommand "test-age-plugin-se-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
        age-plugin-se --help
        touch $out
      '';
    };

    meta = {
      inherit (age-plugin-se.meta) description homepage license;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      mainProgram = "age-plugin-se";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
)
