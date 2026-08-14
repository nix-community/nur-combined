{
  # keep-sorted start
  fetchFromGitHub,
  mkShaders,
  # keep-sorted end
}: let
  version = "unstable-2026-04-14";

  owner = "hced";
  repo = "ghostty-cursor-trails";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "78f597cf66427bc382077e5e33f26981a86bb207";
    hash = "sha256-NHeCd/avyJ8SaYW8pYWcetwVroFQNokN7saiWCMu3TM=";
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
      boo = "boo-cursor.glsl";
      tinkle = "tinkle-cursor.glsl";
      wisp = "wisp-cursor.glsl";
      # keep-sorted end
    };
  }
