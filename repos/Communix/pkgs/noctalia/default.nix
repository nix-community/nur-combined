# adapted from upstream https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/package.nix
{
  lib,
  config,
  stdenv,
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
  git,
  cairo,
  pango,
  harfbuzz,
  libxkbcommon,
  sdbus-cpp_2,
  systemd,
  pipewire,
  pam,
  curl,
  libwebp,
  glib,
  polkit,
  librsvg,
  libqalculate,
  libxml2,
  md4c,
  libsecret,
  libsodium,
  stb,
  fetchFromGitHub,
  nlohmann_json,
  tomlplusplus,
  wireplumber,
  jemalloc,
  autoAddDriverRunpath,
  makeWrapper,
  cudaSupport ? config.cudaSupport,
}:
let
  version = "5.0.0-beta.4";
  stb' = stb.overrideAttrs (_: {
    version = "unstable-2025-10-26";
    src = fetchFromGitHub {
      owner = "nothings";
      repo = "stb";
      rev = "f1c79c02822848a9bed4315b12c8c8f3761e1296";
      hash = "sha256-BlyXJtAI7WqXCTT3ylww8zoG0hBxaojJnQDvdQOXJPE=";
    };
  });
in
stdenv.mkDerivation {
  pname = "noctalia";
  inherit version;

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia";
    tag = "v${version}";
    hash = "sha256-jXz2vFHgidbyU46ScROLSuBIhsqqtyqNu2M0tmGX/FA=";
  };

  postFixup = ''
    wrapProgram $out/bin/noctalia \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    jemalloc
    makeWrapper
  ]
  ++ lib.optional cudaSupport autoAddDriverRunpath;

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libglvnd
    freetype
    fontconfig
    cairo
    pango
    harfbuzz
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
    libqalculate
    libxml2
    md4c
    libsecret
    libsodium
    stb'
    nlohmann_json
    tomlplusplus
  ];

  mesonBuildType = "release";

  ninjaFlags = [ "-v" ];

  meta = with lib; {
    description = "A sleek, customizable desktop shell crafted for Wayland.";
    homepage = "https://github.com/noctalia-dev/noctalia-shell";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "noctalia";
  };
}
