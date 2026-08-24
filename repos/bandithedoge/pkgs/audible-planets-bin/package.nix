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
  version = "1.2.3a";
  shortVersion = lib.removeSuffix "a" version;
  sources = {
    lv2 = fetchurl {
      url = "https://github.com/gregrecco67/AudiblePlanets/releases/download/v${shortVersion}/Audible.Planets-${version}-Linux.lv2.zip";
      hash = "sha256-pHZj3N8T2H+ftfcQ1vy5OxWaSLwR2MnkcvYL8ZmtfHg=";
    };
    vst3 = fetchurl {
      url = "https://github.com/gregrecco67/AudiblePlanets/releases/download/v${shortVersion}/Audible.Planets-${version}-Linux.vst3.zip";
      hash = "sha256-Gfy7VfWe03O0npaKOmb0bIoWVB/f1t/rdt8yzZKDk9A=";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "audible-planets-bin";
  inherit version;
  srcs = builtins.attrValues sources;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{lv2,vst3}
    cp -r "Audible Planets.lv2" $out/lib/lv2
    cp -r "Audible Planets.vst3" $out/lib/vst3

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-audible-planets-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/gregrecco67/AudiblePlanets/releases/latest \
        | jq -r '.name | scan("v(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        format:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${format} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "An expressive, quasi-Ptolemaic semi-modular synthesizer";
    homepage = "https://github.com/gregrecco67/AudiblePlanets";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
