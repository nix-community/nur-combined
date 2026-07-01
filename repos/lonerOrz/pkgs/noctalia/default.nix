{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,

  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  libGL,
  libglvnd,
  freetype,
  fontconfig,
  cairo,
  pango,
  libxkbcommon,
  sdbus-cpp_2,
  systemd,
  pipewire,
  wireplumber,
  pam,
  curl,
  libwebp,
  glib,
  polkit,
  librsvg,
  jemalloc,
  libqalculate,

  withLto ? false,
  withNative ? false,
}:

let
  current = lib.trivial.importJSON ./version.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "noctalia";
  version = current.version;

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia";
    rev = current.rev;
    hash = current.hash;
  };

  postPatch =
    let
      shortRev = lib.substring 0 8 finalAttrs.src.rev;
    in
    ''
      substituteInPlace meson.build \
        --replace-fail "'-march=native', '-mtune=native'," ""

      substituteInPlace src/core/git_revision.h.in \
        --replace-fail "@VCS_TAG@" "${shortRev}"
    '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libglvnd
    freetype
    fontconfig
    cairo
    pango
    libxkbcommon
    sdbus-cpp_2
    systemd
    pipewire
    wireplumber
    pam
    curl
    libwebp
    glib
    polkit
    librsvg
    jemalloc
    libqalculate
  ];

  mesonFlags = [
    "-Db_lto=${lib.boolToString withLto}"
  ];

  NIX_CFLAGS_COMPILE = lib.optionalString withNative "-march=native -mtune=native";

  mesonBuildType = "release";

  ninjaFlags = [ "-v" ];

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = finalAttrs.pname;
    versionFile = "pkgs/noctalia/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubGit {
      owner = "noctalia-dev";
      repo = "noctalia";
    }}";
  };

  meta = {
    description = "Lightweight Wayland shell and bar built directly on Wayland + OpenGL ES";
    homepage = "https://github.com/noctalia-dev/noctalia";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "noctalia";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
