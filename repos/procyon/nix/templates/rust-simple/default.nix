let
  getFlake = builtins.getFlake or getFlakeCompat;
  getFlakeCompat = path:
    let
      lock = builtins.fromJSON (builtins.readFile "${path}/flake.lock");
      inherit (lock.nodes.flake-compat.locked) owner repo rev narHash;
      flake-compat = fetchTarball {
        url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = narHash;
      };
      flake = import flake-compat { src = path; };
    in
    flake.defaultNix;
in
getFlake (toString ./.)
