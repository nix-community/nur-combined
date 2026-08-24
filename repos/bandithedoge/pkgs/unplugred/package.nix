{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  pname = "unplugred";
  version = "0-unstable-2026-07-06";
  src = fetchFromGitHub {
    owner = "unplugred";
    repo = "vsts";
    rev = "4569a1041370b4c30b3a412dbf36089bcf430894";
    hash = "sha256-U4vRkhQuTh4YOUuyEvFzXGjS/lWacCmFL8HxG0t83xA=";
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  patches = [
    # HACK: https://github.com/unplugred/vsts/issues/7
    ./remove_fmplus.patch
  ];

  preInstall = ''
    cp -r plugins/*/*_artefacts .
  '';

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${
      fetchFromGitHub {
        owner = "juce-framework";
        repo = "JUCE";
        rev = "7.0.12";
        hash = "sha256-/awe6D824ZjF17xjkt0wY7dcDuS/s8KKAv1UKHxF0FM=";
      }
    }"
    "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${
      fetchFromGitHub {
        owner = "free-audio";
        repo = "clap-juce-extensions";
        rev = "c1a5ad025f95d01e03267857fa8276ebeed16500";
        hash = "sha256-P8rLNI9fXGU8yxXXdOkRD/+T3AMd3zdRM8mHp62dEmA=";
        fetchSubmodules = true;
      }
    }"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Collection of VST plugins made by unplugred";
    homepage = "https://vst.unplug.red";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    broken = true;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
