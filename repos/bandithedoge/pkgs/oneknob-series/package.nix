{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  pkg-config,
}:
stdenv.mkDerivation {
  pname = "oneknob-series";
  version = "0-unstable-2025-12-21";
  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "OneKnob-Series";
    rev = "0a6ed4e54c0e7380abe9191c2b1b951a3bbc87c3";
    hash = "sha256-8CCMkti8Y6SmbhD/apK0LHr41Fnn5qQ99SfzolGi82E=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  postPatch = ''
    patchShebangs .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,lv2,vst3,vst,ladspa}
    cp bin/*.clap $out/lib/clap
    cp -r bin/*.lv2 $out/lib/lv2
    cp -r bin/*.vst3 $out/lib/vst3
    cp bin/*-vst.so $out/lib/vst
    cp bin/*-ladspa.so $out/lib/ladspa

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Collection of stupidly simple but well-polished and visually pleasing audio plugins";
    homepage = "https://github.com/DISTRHO/OneKnob-Series";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
