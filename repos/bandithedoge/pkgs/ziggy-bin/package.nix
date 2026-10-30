{
  fetchzip,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
}:
let
  version = "0.3.0";
  sources = {
    aarch64-darwin = fetchzip {
      url = "https://github.com/kristoff-it/ziggy/releases/download/v${version}/aarch64-macos.zip";
      hash = "sha256-0hOzC69FDXB/c9BBnnrY1t6yGoVIpcwqoJQjFAeVskE=";
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/kristoff-it/ziggy/releases/download/v${version}/aarch64-linux.tar.xz";
      hash = "sha256-Z2NAJhEGXau2xXj++fRVX2Ydvb8Y/UFat3VkxVmt3Ns=";
    };
    x86_64-linux = fetchzip {
      url = "https://github.com/kristoff-it/ziggy/releases/download/v${version}/x86_64-linux-musl.tar.xz";
      hash = "sha256-eMv/xjZ3huz2tyUgoPick7I76abmQZD1cNzehF6VmOA=";
    };
  };
in
stdenv.mkDerivation {
  pname = "ziggy-bin";
  inherit version;
  src = sources.${stdenv.targetPlatform.system} or sources.x86_64-linux;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    cp ziggy $out/bin

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-ziggy-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/kristoff-it/ziggy/releases/latest | jq -r '.tag_name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Data serialization language for expressing clear API messages, config files, etc.";
    homepage = "https://ziggy-lang.io/";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ziggy";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
