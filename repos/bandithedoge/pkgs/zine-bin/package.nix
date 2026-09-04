{
  fetchzip,
  lib,
  stdenv,
  writeScript,
}:
let
  version = "0.14.0";
  sources = {
    aarch64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-macos.zip";
      hash = "sha256-y+9jE8KdjdcNpU+etSx8InF1rjILc9dbhLLknSVU4I4=";
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-linux-musl.tar.xz";
      hash = "sha256-Bw90giM9Mjm9hOG6GcIW1QV5k4/sERVFjEOqHM0V7Zk=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-macos.zip";
      hash = "sha256-wP7YcoKV/bFZLNmPKBGGBJdsA3wdn6UMcIWZvf6JlMM=";
    };
    x86_64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-linux-musl.tar.xz";
      hash = "sha256-Te+rT1mgHYhOeP89AhAcb+mKnA4AklnwsNRwNgX5lAo=";
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
