{
  stdenv,
  fetchFromGitLab,
  fetchurl,
  ffmpeg,
  meson,
  openjdk17,
  python3,
  lib,
  pkg-config,
  wayland-protocols,
  wayland,
  wayland-scanner,
  gtk4,
  openxr-loader,
  libglvnd,
  libsecret,
  libportal-gtk4,
  sqlite,
  libdrm,
  libgudev,
  webkitgtk_6_0,
  ninja,
  art-standalone,
  bionic-translation,
  alsa-lib,
  makeWrapper,
  nixosTests,
  bintools,
  git,
  nix,
  writeShellApplication,
}:

let
  asm = fetchurl {
    url = "https://repo1.maven.org/maven2/org/ow2/asm/asm/9.7.1/asm-9.7.1.jar";
    hash = "sha256-jK3UOsXrbQneBfrsyji5F6BAu5E5x+3rTMgcdAtxMoE=";
  };
  asmTree = fetchurl {
    url = "https://repo1.maven.org/maven2/org/ow2/asm/asm-tree/9.7.1/asm-tree-9.7.1.jar";
    hash = "sha256-mSmIH1nra4QOhtVFcMd7Wc5yHRBObf16QJeJkcLTtB8=";
  };
  javaGetopt = fetchurl {
    url = "https://repo1.maven.org/maven2/gnu/getopt/java-getopt/1.0.13/java-getopt-1.0.13.jar";
    hash = "sha256-8J3GNp/8T+Q2LL1JtqxsSnRxN1rF2ITHGwpiWoicOMQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "android-translation-layer";
  version = "0-unstable-2026-11-04";

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "android_translation_layer";
    rev = "bbb4d469405cdaea585475b17daef13202bc7e23";
    hash = "sha256-fgRoIiMCkIdRtPwIl47BviJX8L9VBd/xIS9gz7IDne8=";
  };

  patches = [
    # Required gio-unix dependency is missing in meson.build
    ./add-gio-unix-dep.patch

    # Patch custon Dex install dir
    ./configure-dex-install-dir.patch
  ];

  postPatch = ''
    # As we need the $out reference, we can't use `replaceVars` here.
    substituteInPlace src/main-executable/main.c \
      --replace-fail '@out@' "$out"

    sed -i -E \
      "s|^xmvn_resolve = find_program.*$|xmvn_resolve = find_program('xmvn5-resolve', required: false)|" \
      tools/jni_upcall_gen/meson.build
    substituteInPlace tools/jni_upcall_gen/meson.build \
      --replace-fail "cmd = ['build.py'" "cmd = [find_program('python3'), files('build.py')"

    substituteInPlace tools/jni_upcall_gen/jni_upcall_gen.in \
      --replace-fail '#!/bin/bash' '#!/bin/sh'

    substituteInPlace tools/jni_upcall_gen/build.py \
      --replace-fail 'p = subprocess.run(["xmvn5-resolve", "-rc"] + deps_system, capture_output=True, text=True)' 'p = None; deps_system_classpath = "${asm}:${asmTree}:${javaGetopt}"' \
      --replace-fail 'deps_system_classpath = p.stdout.strip()' '# substituted'
    patchShebangs tools/jni_upcall_gen/build.py
  '';

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    openjdk17
    pkg-config
    python3
  ];

  buildInputs = [
    alsa-lib
    art-standalone
    bionic-translation
    ffmpeg
    gtk4
    libdrm
    libglvnd
    libsecret
    libgudev
    libportal-gtk4
    openxr-loader
    sqlite
    wayland
    wayland-protocols
    wayland-scanner
    webkitgtk_6_0
  ];

  postFixup = ''
    wrapProgram $out/bin/android-translation-layer \
      --prefix LD_LIBRARY_PATH : ${art-standalone}/lib/art \
      --prefix PATH : ${
        lib.makeBinPath [
          art-standalone # dex2oat
          bintools # addr2line
        ]
      }
  '';

  passthru.tests = {
    inherit (nixosTests) android-translation-layer;
  };

  passthru.updateScript = writeShellApplication {
    name = "update-android-translation-layer";
    runtimeInputs = [
      git
      nix
      python3
    ];
    text = ''
      cd "$(git rev-parse --show-toplevel)"
      exec python3 ${../../../scripts/update-gitlab-unstable.py} \
        by-name/an/android-translation-layer \
        gitlab.com/android_translation_layer/android_translation_layer \
        android-translation-layer "$@"
    '';
  };

  meta = {
    description = "Translation layer that allows running Android apps on a Linux system";
    homepage = "https://gitlab.com/android_translation_layer/android_translation_layer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "android-translation-layer";
  };
})
