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

  # This adds header colors to the builds, but it rebuilds the whole
  # world from scratch, so only use it to debug!
  # add it as postHook in derivations
  immaePostHook = ''
    header() {
      echo -ne "\033[1;36m"
      echo -n "$1"
      echo -e "\033[0m"
    }

    echoCmd() {
      printf "\033[1;34m%s:\033[0m" "$1"
      shift
      printf ' %q' "$@"
      echo
    }
  '';

} // (if builtins.pathExists ./lib/private then import ./lib/private else {})
