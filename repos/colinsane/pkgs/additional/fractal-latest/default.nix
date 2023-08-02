{ fractal-next, fetchFromGitLab, rustPlatform }:

(fractal-next.overrideAttrs (prev: rec {
  pname = "fractal-latest";
  version = "unstable-2023-07-28";
  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    rev = "dc66180a44e4e996db0e840dab0be08d826a5319";
    hash = "sha256-SYkeHkNlxHbsd+kubGZO5PEA9mg9Id0pHDi/2MMGy90=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "matrix-sdk-0.6.2" = "sha256-ofaXdhkbDa7/tp/RdBQ1/JBaSims8znJ66NeRUhof20=";
      "ruma-0.8.2" = "sha256-ZlevGTGL/DQVAYeR078I0cT/V1kaubhORgt1cZUhBqM=";
      # "vodozemac-0.3.0" = "sha256-tAimsVD8SZmlVybb7HvRffwlNsfb7gLWGCplmwbLIVE=";
      "x25519-dalek-1.2.0" = "sha256-AHjhccCqacu0WMTFyxIret7ghJ2V+8wEAwR5L6Hy1KY=";
    };
  };
}))
