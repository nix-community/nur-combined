{ fractal-next
, fetchFromGitLab
, rustPlatform
, unstableGitUpdater
}:

let
  # libadwaita_1_4 = libadwaita.overrideAttrs (prev: rec {
  #   # 2023/09/27: nixpkgs libadwaita is 1.3.5 and fractal requires 1.4.0.
  #   version = "1.4.0";
  #   src = fetchFromGitLab {
  #     domain = "gitlab.gnome.org";
  #     owner = "GNOME";
  #     repo = "libadwaita";
  #     rev = version;
  #     hash = "sha256-LXrlTca50ALo+Nm55fwXNb4k3haLqHNnzLPc08VhA5s=";
  #   };
  # });
  self = fractal-next.overrideAttrs (prev: rec {
    pname = "fractal-latest";
    # XXX(2023/09/27): beyond this commit, dependencies are higher than what nixpkgs provides:
    # - gtk4 >= 4.11.3
    # - libadwaita >= 1.4.0
    version = "unstable-2023-09-14";
    src = fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "fractal";
      rev = "350a65cb0a221c70fc3e4746898036a345ab9ed8";
      hash = "sha256-z6uURqMG5pT8rXZCv5IzTjXxtt/f4KUeCDSgk90aWdo=";
    };

    passthru.updateScript = unstableGitUpdater {};

    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        # hashes for git dependencies (?). when updating the package:
        # 1. reset this to {}
        # 2. build, it will fail, but warn that a hash is missing here
        # 3. add "<crate_thats_missing_hash>" = "";
        # 4. repeat until no more crates are missing hashes
        # 5. build, and nix will let you know what the actual hashes should be
        "curve25519-dalek-4.0.0" = "sha256-sxEFR6lsX7t4u/fhWd6wFMYETI2egPUbjMeBWkB289E=";
        "matrix-sdk-0.6.2" = "sha256-A1oKNbEx2A6WwvYcNSW53Fd6QWwr0QFJtrsJXO2KInE=";
        "ruma-0.8.2" = "sha256-kCGS7ACFGgmtTUElLJQMYfjwJ3glF7bRPZYJIFcuPtc=";
        "vodozemac-0.4.0" = "sha256-TCbWJ9bj/FV3ILWUTcksazel8ESTNTiDGL7kGlEGvow=";
      };
    };
  });
in self // {
  meta = self.meta // {
    # ensure nix thinks the canonical position of this derivation is inside my own repo,
    # not upstream nixpkgs repo. this ensures that the updateScript can patch the version/hash
    # of the right file. meta.position gets overwritten if set in overrideAttrs, hence this
    # manual `//` hack
    position = let
      pos = builtins.unsafeGetAttrPos "updateScript" self.passthru;
    in "${pos.file}:${builtins.toString pos.line}";
  };
}
