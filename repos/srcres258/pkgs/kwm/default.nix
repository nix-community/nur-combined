{ pkgs
, stdenv
, fetchFromGitHub
, zig_0_17
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
  # Tracks the `own` branch of the fork instead of the v0.3.0.2 tag: the tag
  # still requires Zig 0.16, while this commit is the Zig 0.17 port. Bump this
  # deliberately instead of following the branch, so a rebuild always describes
  # the same tree.
  rev = "eb109c23c118eb2d46e7256ec2ee2c3252fe600c";
in {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "srcres258";
    repo = "kwm";
    inherit rev;
    hash = "sha256-maAUQwdf6zCYaB+WJaLAwIJOQq3+JKlBrSnFIZn4Qd0=";
  };

  nativeBuildInputs = [
    zig_0_17
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

  zigDeps = zig_0_17.fetchDeps {
    inherit (finalAttrs) src pname version;
    fetchAll = true;
    hash = "sha256-XoY5gM7cqEqAr/E6e9a/W2pQkvU8mqdL1HbMrjnQI4w=";
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
