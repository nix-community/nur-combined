{ pkgs
, stdenv
, fetchFromGitHub
, zig_0_16
, pkg-config
, wayland
, wayland-protocols
, wayland-scanner
, libxkbcommon
, fcft
, pixman
, maintainers
, ...
}:

stdenv.mkDerivation (finalAttrs: (let
  pname = "kwm";
  version = "0.3.0.2";
in {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "srcres258";
    repo = "kwm";
    rev = "v${version}";
    hash = "sha256-VgrWcdh7LEJUlQH/y6coomvXdxxvOasqH5BC+xJWRWA=";
  };

  nativeBuildInputs = [
    zig_0_16
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    pixman
    fcft
  ];

  zigDeps = zig_0_16.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-Lz/Wcy40rxN81n/mBj4YJVbyGOolHzSFZMs93T1h0oQ=";
  };

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  zigBuildFlags = [
    "-Doptimize=ReleaseSafe"
    "-Dbar=true"
    "-Dkwim=false"
  ];

  dontUseZigCheck = true;

  meta = with pkgs.lib; {
    description = "kewuaa's Window Manager for river";
    homepage = "https://github.com/kewuaa/kwm";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = pname;
    maintainers = with maintainers; [ srcres258 ];
  };
}))
