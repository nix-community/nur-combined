{ pkgs
, stdenv
, fetchFromGitHub
, zig_0_16
, pkg-config
, wayland
, wayland-protocols
, wayland-scanner
, libxkbcommon
, maintainers
, ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kwm";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kewuaa";
    repo = "kwm";
    rev = "v0.3.0"; # v0.3.0 对应提交；也可以直接写 tag
    hash = "sha256-hX76wTHPTgg5RAHILfd3CjRKPlgAwGSK3lG82IFoUUs=";
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
    mainProgram = "kwm";
    maintainers = with maintainers; [ srcres258 ];
  };
})
