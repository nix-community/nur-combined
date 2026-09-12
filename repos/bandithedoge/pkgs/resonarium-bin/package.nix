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
  version = "0.1.1";
  sources = {
    instrument = fetchurl {
      url = "https://github.com/gabrielsoule/resonarium/releases/download/v${version}/Resonarium-Instrument-${version}-Linux.zip";
      sha256 = "sha256-Sb5nkmLHQh743dYR/azDWQ5aesOBs88g19OnoXEl1GQ=";
    };
    effect = fetchurl {
      url = "https://github.com/gabrielsoule/resonarium/releases/download/v${version}/Resonarium-Effect-${version}-Linux.zip";
      sha256 = "sha256-13ws0wdssT0dDOEey2YCv82Ph1qiBRTc+4WORSZUH9M=";
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
