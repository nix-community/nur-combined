{
  # keep-sorted start
  fetchFromGitHub,
  mkShaders,
  # keep-sorted end
}: let
  version = "unstable-2026-06-16";

  owner = "sahaj-b";
  repo = "ghostty-cursor-shaders";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "0a274beac8b93ee6ce6b94402b7313a0417b8e38";
    hash = "sha256-B7B6K7Ee4uJlW8zzLP3ILgddnbcIQyNimY+rVllzbR0=";
  };
in
  mkShaders {
    inherit
      # keep-sorted start
      src
      version
      # keep-sorted end
      ;
    homepage = "https://github.com/${owner}/${repo}";

    shaders = {
      # keep-sorted start
      cursor-sweep = "cursor_sweep.glsl";
      cursor-tail = "cursor_tail.glsl";
      cursor-warp = "cursor_warp.glsl";
      rectangle-boom-cursor = "rectangle_boom_cursor.glsl";
      ripple-cursor = "ripple_cursor.glsl";
      ripple-rectangle-cursor = "ripple_rectangle_cursor.glsl";
      sonic-boom-cursor = "sonic_boom_cursor.glsl";
      # keep-sorted end
    };
  }
