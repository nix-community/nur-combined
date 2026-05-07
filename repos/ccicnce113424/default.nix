let
  lockFile = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat-node = lockFile.nodes.${lockFile.nodes.root.inputs.flake-compat};
  flake-compat =
    let
      inherit (flake-compat-node) locked;
    in
    fetchTarball {
      url =
        locked.url or (
          if locked.type == "github" then
            "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz"
          else
            throw "Unsupported source type ${locked.type} for flake-compat"
        );
      sha256 = locked.narHash;
    };

  flake = (
    import flake-compat {
      src = ./.;
      copySourceTreeToStore = false;
      # useBuiltinsFetchTree = true;
    }
  );
in
flake.defaultNix
