# { pkgs }:
# with pkgs.lib;
rec {
  
  fetchTarballFromGitHub =
    { owner, repo, rev, sha256, ... }:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/tarball/${rev}";
      inherit sha256;
  };

  fromJSONFile = f: builtins.fromJSON (builtins.readFile f);

  seemsDarwin = null != builtins.match ".*darwin$" builtins.currentSystem;

  pinnedNixpkgs = args@{ rev, sha256, ... }:
    let args' = args // { owner = "NixOS"; repo = "nixpkgs"; }; in
    import (fetchTarballFromGitHub args') {};
  
}
