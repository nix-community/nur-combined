{
  fetchurl,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
let
  version = "0.1.0";
  sources = {
    instrument = fetchurl {
      url = "https://github.com/gabrielsoule/resonarium/releases/download/v${version}/Resonarium-Instrument-${version}-Linux.zip";
      sha256 = "sha256-qDJU90fEShT4LCrgEn/etCwy8mPgCjxXn8+CB1Hxuc0=";
    };
    effect = fetchurl {
      url = "https://github.com/gabrielsoule/resonarium/releases/download/v${version}/Resonarium-Effect-${version}-Linux.zip";
      sha256 = "sha256-GFos0HLM6CTU99DLB6e4OuySgODcZDdxheM+K2VHOUY=";
    };
  };
in
stdenv.mkDerivation {
  pname = "resonarium-bin";
  inherit version;
  srcs = builtins.attrValues sources;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/{bin,lib/vst3}
    cp Standalone/* $out/bin
    cp -r VST3/* $out/lib/vst3
  '';

  passthru = sources // {
    updateScript = writeScript "update-audible-planets-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/gabrielsoule/resonarium/releases/latest \
        | jq -r '.tag_name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        format:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${format} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "An expressive, semi-modular, and comprehensive physical modeling/waveguide synthesizer";
    homepage = "https://github.com/gabrielsoule/resonarium";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Resonarium";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
