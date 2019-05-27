{ pkgs }:
with pkgs;
rec {
  yarn2nixPackage = let
    src = builtins.fetchGit {
      url = "git://github.com/moretea/yarn2nix.git";
      ref = "master";
      rev = "780e33a07fd821e09ab5b05223ddb4ca15ac663f";
    };
  in
    (callPackage src {}) // { inherit src; };

  nodeEnv = import ./node-env.nix;

  fetchedGithub = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      name = "${json.meta.name}-${version}";
      src = fetchFromGitHub json.github;
    };

  fetchedGit = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      name = "${json.meta.name}-${version}";
      src = fetchgit json.git;
    };

  fetchedGitPrivate = path:
    let
      json = lib.importJSON path;
    in rec {
      version = json.tag;
      name = "${json.meta.name}-${version}";
      src = builtins.fetchGit {
        url = json.git.url;
        ref = "master";
        rev = json.git.rev;
      };
    };

  wrap = { paths ? [], vars ? {}, file ? null, script ? null, name ? "wrap" }:
    assert file != null || script != null ||
      abort "wrap needs 'file' or 'script' argument";
    with rec {
      set  = n: v: "--set ${pkgs.lib.escapeShellArg n} " +
                    "${pkgs.lib.escapeShellArg v}";
      args = (map (p: "--prefix PATH : ${p}/bin") paths) ++
            (builtins.attrValues (pkgs.lib.mapAttrs set vars));
    };
    runCommand name
      {
        f           = if file == null then writeScript name script else file;
        buildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper "$f" "$out" ${toString args}
      '';

} // (if builtins.pathExists ./private then callPackage ./private {} else {})
