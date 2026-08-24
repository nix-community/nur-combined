{
  fetchzip,
  lib,
  stdenv,
  writeScript,
}:
let
  version = "0.13.0";
  sources = {
    aarch64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-macos.zip";
      hash = "sha256-F0bV7MDFnSYY7rq0oBNEmzBXNLkzRyLgD7znbpAfpAg=";
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/aarch64-linux-musl.tar.xz";
      hash = "sha256-SAFAwNGmIbCXJVk7c5xxLzU5bqtHDWP8QRRnnMst7iY=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-macos.zip";
      hash = "sha256-BNseQTcDYZJ/mcYHUZPukut+U2rm1O/GdDaD6RYhOE0=";
    };
    x86_64-linux = fetchzip {
      url = "https://github.com/kristoff-it/zine/releases/download/v${version}/x86_64-linux-musl.tar.xz";
      hash = "sha256-t1B69T8bDv6M80rW0EPj7cR5/vGhPGy606LSzzNnqwg=";
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
