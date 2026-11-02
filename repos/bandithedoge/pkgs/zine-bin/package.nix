{
  fetchzip,
  lib,
  stdenv,
  writeScript,
}:
let
  version = "0.14.1";
  sources = {
    aarch64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-macos.zip";
      hash = "sha256-JPameR10TWLp/1ZrvSkHR0kP/vwSHXrkz57buTH97zU=";
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-linux-musl.tar.xz";
      hash = "sha256-TUSuYs/1X0vQztpc3QVOSumCftR7YTFfxtmv0apWEsg=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-macos.zip";
      hash = "sha256-30DvdXxvtYE1ENJOFJR2qaMb8arsXnbEtlV94qfipcM=";
    };
    x86_64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-linux-musl.tar.xz";
      hash = "sha256-v5YZnJWFt8y0vw7yhDBtlZiGokp3EiQV3z/f5MCresI=";
    };
  };
in
stdenv.mkDerivation {
  pname = "zine-bin";
  inherit version;
  src = sources.${stdenv.targetPlatform.system} or sources.x86_64-linux;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    chmod +x zine
    cp zine $out/bin

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-ziggy-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/kristoff-it/zine/releases/latest | jq -r '.tag_name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Fast, Scalable, Flexible Static Site Generator (SSG)";
    homepage = "https://zine-ssg.io";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "zine-bin";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
